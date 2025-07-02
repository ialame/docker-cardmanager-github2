#!/bin/bash
echo "🔧 Solution simplifiée - Correction complète..."

# 1. Nettoyer
rm -rf docker/
docker-compose down 2>/dev/null || true

# 2. Créer la structure
mkdir -p docker/mason docker/painter docker/gestioncarte

# 3. Créer le POM parent (fichier séparé)
cat > docker/parent-pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.pcagrade</groupId>
    <artifactId>cardmanager</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>
    <properties>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    <modules>
        <module>mason</module>
        <module>painter</module>
        <module>gestioncarte</module>
    </modules>
</project>
EOF

# 4. Dockerfile Mason (simplifié)
cat > docker/mason/Dockerfile << 'EOF'
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /usr/src/app

# Cloner Mason
RUN git clone --depth 1 --branch main https://github.com/ialame/mason.git mason

# Copier le POM parent
COPY docker/parent-pom.xml pom.xml

# Build Mason
RUN mvn clean install -DskipTests

# Image finale
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -g 1000 appgroup && adduser -u 1000 -G appgroup -s /bin/sh -D appuser
USER appuser
CMD ["java", "-version"]
EOF

# 5. Dockerfile Painter
cat > docker/painter/Dockerfile << 'EOF'
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /usr/src/app

# Cloner les dépôts
RUN git clone --depth 1 --branch main https://github.com/ialame/mason.git mason
RUN git clone --depth 1 --branch main https://github.com/ialame/painter.git painter

# Copier le POM parent
COPY docker/parent-pom.xml pom.xml

# Build
RUN mvn clean install -DskipTests

# Image finale
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /usr/src/app/painter/target/painter-*.jar app.jar
RUN mkdir -p /app/images
EXPOSE 8081
CMD ["java", "-jar", "app.jar"]
EOF

# 6. Dockerfile GestionCarte
cat > docker/gestioncarte/Dockerfile << 'EOF'
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /usr/src/app

# Cloner les dépôts
RUN git clone --depth 1 --branch main https://github.com/ialame/mason.git mason
RUN git clone --depth 1 --branch main https://github.com/ialame/painter.git painter
RUN git clone --depth 1 --branch main https://github.com/ialame/gestioncarte.git gestioncarte

# Copier le POM parent
COPY docker/parent-pom.xml pom.xml

# Build
RUN mvn clean install -DskipTests

# Image finale
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /usr/src/app/gestioncarte/target/retriever-*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
EOF

# 7. Créer nginx-images.conf s'il n'existe pas
if [ ! -f "nginx-images.conf" ]; then
    cat > nginx-images.conf << 'EOF'
server {
    listen 80;
    server_name localhost;

    location /images/ {
        alias /usr/share/nginx/html/images/;
        add_header Access-Control-Allow-Origin *;
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
    }

    location / {
        return 200 '<!DOCTYPE html><html><head><title>CardManager Images</title></head><body><h1>🖼️ CardManager Images Server</h1><p><a href="/images/">Browse Images</a></p></body></html>';
        add_header Content-Type text/html;
    }

    location /health {
        return 200 '{"status":"ok","service":"images"}';
        add_header Content-Type application/json;
    }
}
EOF
fi

# 8. Créer docker-compose.yml simplifié
cat > docker-compose.yml << 'EOF'
services:
  mariadb-standalone:
    image: mariadb:11.2
    container_name: cardmanager-mariadb
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: dev
      MYSQL_USER: ia
      MYSQL_PASSWORD: foufafou
    ports:
      - "3307:3306"
    volumes:
      - cardmanager_db_data:/var/lib/mysql
    networks:
      - cardmanager-network
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      start_period: 60s
      interval: 10s
      timeout: 5s
      retries: 10
    restart: unless-stopped

  mason:
    build:
      context: .
      dockerfile: docker/mason/Dockerfile
    container_name: cardmanager-mason
    depends_on:
      mariadb-standalone:
        condition: service_healthy
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mariadb://mariadb-standalone:3306/dev
      - SPRING_DATASOURCE_USERNAME=ia
      - SPRING_DATASOURCE_PASSWORD=foufafou
      - SPRING_PROFILES_ACTIVE=docker
    networks:
      - cardmanager-network
    restart: unless-stopped

  painter:
    build:
      context: .
      dockerfile: docker/painter/Dockerfile
    container_name: cardmanager-painter
    ports:
      - "8081:8081"
    depends_on:
      mariadb-standalone:
        condition: service_healthy
      mason:
        condition: service_started
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mariadb://mariadb-standalone:3306/dev
      - SPRING_DATASOURCE_USERNAME=ia
      - SPRING_DATASOURCE_PASSWORD=foufafou
      - SPRING_PROFILES_ACTIVE=docker
      - PAINTER_IMAGE_STORAGE_PATH=/app/images
    volumes:
      - cardmanager_images:/app/images
    networks:
      - cardmanager-network
    restart: unless-stopped

  gestioncarte:
    build:
      context: .
      dockerfile: docker/gestioncarte/Dockerfile
    container_name: cardmanager-gestioncarte
    ports:
      - "8080:8080"
    depends_on:
      mariadb-standalone:
        condition: service_healthy
      mason:
        condition: service_started
      painter:
        condition: service_started
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mariadb://mariadb-standalone:3306/dev
      - SPRING_DATASOURCE_USERNAME=ia
      - SPRING_DATASOURCE_PASSWORD=foufafou
      - SPRING_PROFILES_ACTIVE=docker
      - PAINTER_SERVICE_URL=http://painter:8081
      - SPRING_LIQUIBASE_ENABLED=false
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
    networks:
      - cardmanager-network
    restart: unless-stopped

  nginx-images:
    image: nginx:alpine
    container_name: cardmanager-nginx
    ports:
      - "8082:80"
    volumes:
      - cardmanager_images:/usr/share/nginx/html/images:ro
      - ./nginx-images.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - painter
    networks:
      - cardmanager-network
    restart: unless-stopped

volumes:
  cardmanager_db_data:
  cardmanager_images:

networks:
  cardmanager-network:
    driver: bridge
EOF

echo ""
echo "✅ Configuration complète créée !"
echo ""
echo "🚀 Maintenant, lancez :"
echo "   docker-compose build --no-cache"
echo "   docker-compose up -d"
echo ""
echo "⏳ Le build va prendre 10-15 minutes la première fois..."