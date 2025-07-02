#!/bin/bash
echo "🔧 Correction des Dockerfiles - Problème Maven résolu..."

# 1. Nettoyer
rm -rf docker/
docker-compose down 2>/dev/null || true

# 2. Créer la structure
mkdir -p docker/mason docker/painter docker/gestioncarte

# 3. Créer le POM parent spécifique pour chaque service
# POM pour Mason (seulement mason)
cat > docker/parent-pom-mason.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.pcagrade</groupId>
    <artifactId>cardmanager-mason</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>
    <properties>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    <modules>
        <module>mason</module>
    </modules>
</project>
EOF

# POM pour Painter (mason + painter)
cat > docker/parent-pom-painter.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.pcagrade</groupId>
    <artifactId>cardmanager-painter</artifactId>
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
    </modules>
</project>
EOF

# POM pour GestionCarte (tous les modules)
cat > docker/parent-pom-gestioncarte.xml << 'EOF'
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

# 4. Dockerfile Mason (corrigé)
cat > docker/mason/Dockerfile << 'EOF'
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /usr/src/app

# Cloner Mason uniquement
RUN git clone --depth 1 --branch main https://github.com/ialame/mason.git mason

# Copier le POM parent spécifique à Mason
COPY docker/parent-pom-mason.xml pom.xml

# Build Mason
RUN mvn clean install -DskipTests

# Image finale
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /usr/src/app/mason/target/mason-*.jar app.jar 2>/dev/null || echo "No mason jar found"
RUN addgroup -g 1000 appgroup && adduser -u 1000 -G appgroup -s /bin/sh -D appuser
USER appuser
EXPOSE 8083
CMD ["java", "-jar", "app.jar"]
EOF

# 5. Dockerfile Painter (corrigé)
cat > docker/painter/Dockerfile << 'EOF'
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /usr/src/app

# Cloner Mason et Painter
RUN git clone --depth 1 --branch main https://github.com/ialame/mason.git mason
RUN git clone --depth 1 --branch main https://github.com/ialame/painter.git painter

# Copier le POM parent spécifique à Painter
COPY docker/parent-pom-painter.xml pom.xml

# Build (Mason en premier, puis Painter)
RUN mvn clean install -DskipTests

# Image finale
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /usr/src/app/painter/target/painter-*.jar app.jar
RUN mkdir -p /app/images
EXPOSE 8081
CMD ["java", "-jar", "app.jar"]
EOF

# 6. Dockerfile GestionCarte (corrigé)
cat > docker/gestioncarte/Dockerfile << 'EOF'
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /usr/src/app

# Cloner tous les dépôts
RUN git clone --depth 1 --branch main https://github.com/ialame/mason.git mason
RUN git clone --depth 1 --branch main https://github.com/ialame/painter.git painter
RUN git clone --depth 1 --branch main https://github.com/ialame/gestioncarte.git gestioncarte

# Copier le POM parent complet
COPY docker/parent-pom-gestioncarte.xml pom.xml

# Build tous les modules (Mason -> Painter -> GestionCarte)
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

# 8. Créer docker-compose.yml avec les bonnes dépendances
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
    ports:
      - "8083:8083"
    networks:
      - cardmanager-network
    restart: unless-stopped

  painter:
    build:
      context: .
      dockerfile: docker/painter/Dockerfile
    container_name: cardmanager-painter
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
      - MASON_SERVICE_URL=http://mason:8083
    ports:
      - "8081:8081"
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
      - MASON_SERVICE_URL=http://mason:8083
      - PAINTER_SERVICE_URL=http://painter:8081
    ports:
      - "8080:8080"
    networks:
      - cardmanager-network
    restart: unless-stopped

  nginx-images:
    image: nginx:alpine
    container_name: cardmanager-nginx-images
    ports:
      - "8082:80"
    volumes:
      - cardmanager_images:/usr/share/nginx/html/images:ro
      - ./nginx-images.conf:/etc/nginx/conf.d/default.conf:ro
    networks:
      - cardmanager-network
    restart: unless-stopped
    depends_on:
      - painter

volumes:
  cardmanager_db_data:
    driver: local
  cardmanager_images:
    driver: local

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
echo "🔍 Pour suivre les logs : docker-compose logs -f"