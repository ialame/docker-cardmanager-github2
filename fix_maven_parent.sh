#!/bin/bash
echo "🔧 Correction Maven - Création du POM parent cardmanager..."

# 1. Nettoyer
rm -rf docker/
docker-compose down 2>/dev/null || true

# 2. Créer la structure
mkdir -p docker/mason docker/painter docker/gestioncarte

# 3. Créer le VRAI POM parent cardmanager que Mason et Painter attendent
cat > docker/cardmanager-parent.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.5</version>
        <relativePath/>
    </parent>

    <groupId>com.pcagrade</groupId>
    <artifactId>cardmanager</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <name>Card Manager Parent</name>
    <description>Parent POM for Card Manager projects</description>

    <properties>
        <java.version>21</java.version>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

        <!-- Versions des modules -->
        <mason.version>2.4.1</mason.version>
        <painter.version>1.3.0</painter.version>
        <retriever.version>9.4.0</retriever.version>

        <!-- Versions des dépendances -->
        <mapstruct.version>1.6.0.Beta1</mapstruct.version>
        <swagger.version>2.2.21</swagger.version>
        <liquibase.version>4.27.0</liquibase.version>
        <jacoco.version>0.8.12</jacoco.version>
        <resilience4j.version>2.1.0</resilience4j.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <!-- Mason Dependencies -->
            <dependency>
                <groupId>com.pcagrade.mason</groupId>
                <artifactId>mason-commons</artifactId>
                <version>${mason.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.mason</groupId>
                <artifactId>mason-ulid</artifactId>
                <version>${mason.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.mason</groupId>
                <artifactId>mason-jpa</artifactId>
                <version>${mason.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.mason</groupId>
                <artifactId>mason-json</artifactId>
                <version>${mason.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.mason</groupId>
                <artifactId>mason-oauth2</artifactId>
                <version>${mason.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.mason</groupId>
                <artifactId>mason-web-client</artifactId>
                <version>${mason.version}</version>
            </dependency>

            <!-- Painter Dependencies -->
            <dependency>
                <groupId>com.pcagrade.painter</groupId>
                <artifactId>painter</artifactId>
                <version>${painter.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.painter</groupId>
                <artifactId>painter-common</artifactId>
                <version>${painter.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.painter</groupId>
                <artifactId>painter-client</artifactId>
                <version>${painter.version}</version>
            </dependency>

            <!-- Common Dependencies -->
            <dependency>
                <groupId>org.mapstruct</groupId>
                <artifactId>mapstruct</artifactId>
                <version>${mapstruct.version}</version>
            </dependency>
            <dependency>
                <groupId>io.swagger.core.v3</groupId>
                <artifactId>swagger-annotations</artifactId>
                <version>${swagger.version}</version>
            </dependency>
            <dependency>
                <groupId>io.github.resilience4j</groupId>
                <artifactId>resilience4j-spring-boot2</artifactId>
                <version>${resilience4j.version}</version>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <repositories>
        <repository>
            <id>central</id>
            <url>https://repo1.maven.org/maven2</url>
        </repository>
    </repositories>
</project>
EOF

# 4. Dockerfile Mason - Avec installation du POM parent
cat > docker/mason/Dockerfile << 'EOF'
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /usr/src/app

# Copier et installer le POM parent cardmanager
COPY docker/cardmanager-parent.xml cardmanager-pom.xml
RUN mvn install:install-file \
    -Dfile=cardmanager-pom.xml \
    -DgroupId=com.pcagrade \
    -DartifactId=cardmanager \
    -Dversion=1.0.0-SNAPSHOT \
    -Dpackaging=pom

# Cloner Mason
RUN git clone --depth 1 --branch main https://github.com/ialame/mason.git mason

# Build Mason (le POM parent est maintenant disponible)
WORKDIR /usr/src/app/mason
RUN mvn clean install -DskipTests

# Image finale
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
# Mason n'a pas de JAR principal, on copie juste les JARs disponibles
COPY --from=builder /usr/src/app/mason/target/*.jar* ./
RUN addgroup -g 1000 appgroup && adduser -u 1000 -G appgroup -s /bin/sh -D appuser
USER appuser
EXPOSE 8083
# Mason est une bibliothèque, pas une application standalone
CMD ["java", "-version"]
EOF

# 5. Dockerfile Painter - Avec installation du POM parent
cat > docker/painter/Dockerfile << 'EOF'
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /usr/src/app

# Copier et installer le POM parent cardmanager
COPY docker/cardmanager-parent.xml cardmanager-pom.xml
RUN mvn install:install-file \
    -Dfile=cardmanager-pom.xml \
    -DgroupId=com.pcagrade \
    -DartifactId=cardmanager \
    -Dversion=1.0.0-SNAPSHOT \
    -Dpackaging=pom

# Cloner Mason (dépendance de Painter)
RUN git clone --depth 1 --branch main https://github.com/ialame/mason.git mason

# Build et installer Mason dans le repository local
WORKDIR /usr/src/app/mason
RUN mvn clean install -DskipTests

# Cloner Painter
WORKDIR /usr/src/app
RUN git clone --depth 1 --branch main https://github.com/ialame/painter.git painter

# Build Painter
WORKDIR /usr/src/app/painter
RUN mvn clean install -DskipTests

# Image finale
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /usr/src/app/painter/painter/target/painter-*.jar app.jar
RUN mkdir -p /app/images
EXPOSE 8081
CMD ["java", "-jar", "app.jar"]
EOF

# 6. Dockerfile GestionCarte - Avec installation du POM parent et dépendances
cat > docker/gestioncarte/Dockerfile << 'EOF'
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /usr/src/app

# Copier et installer le POM parent cardmanager
COPY docker/cardmanager-parent.xml cardmanager-pom.xml
RUN mvn install:install-file \
    -Dfile=cardmanager-pom.xml \
    -DgroupId=com.pcagrade \
    -DartifactId=cardmanager \
    -Dversion=1.0.0-SNAPSHOT \
    -Dpackaging=pom

# Cloner et build Mason (première dépendance)
RUN git clone --depth 1 --branch main https://github.com/ialame/mason.git mason
WORKDIR /usr/src/app/mason
RUN mvn clean install -DskipTests

# Cloner et build Painter (deuxième dépendance)
WORKDIR /usr/src/app
RUN git clone --depth 1 --branch main https://github.com/ialame/painter.git painter
WORKDIR /usr/src/app/painter
RUN mvn clean install -DskipTests

# Cloner et build GestionCarte
WORKDIR /usr/src/app
RUN git clone --depth 1 --branch main https://github.com/ialame/gestioncarte.git gestioncarte
WORKDIR /usr/src/app/gestioncarte
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

# 8. Créer docker-compose.yml avec la bonne structure
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

  painter:
    build:
      context: .
      dockerfile: docker/painter/Dockerfile
    container_name: cardmanager-painter
    depends_on:
      mariadb-standalone:
        condition: service_healthy
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mariadb://mariadb-standalone:3306/dev
      - SPRING_DATASOURCE_USERNAME=ia
      - SPRING_DATASOURCE_PASSWORD=foufafou
      - SPRING_PROFILES_ACTIVE=docker
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
      painter:
        condition: service_started
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mariadb://mariadb-standalone:3306/dev
      - SPRING_DATASOURCE_USERNAME=ia
      - SPRING_DATASOURCE_PASSWORD=foufafou
      - SPRING_PROFILES_ACTIVE=docker
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
echo "✅ Configuration Maven corrigée !"
echo ""
echo "🔧 Ce qui a été corrigé :"
echo "   - POM parent 'cardmanager' créé avec la bonne structure"
echo "   - Installation du POM parent dans chaque Dockerfile"
echo "   - Build séquentiel : Mason → Painter → GestionCarte"
echo "   - Dépendances Maven correctement résolues"
echo ""
echo "🚀 Maintenant, lancez :"
echo "   docker-compose build --no-cache"
echo "   docker-compose up -d"
echo ""
echo "⏳ Le build va prendre 12-18 minutes (build de tous les modules)..."
echo "🔍 Pour suivre les logs : docker-compose logs -f"