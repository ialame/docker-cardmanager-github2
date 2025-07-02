#!/bin/bash
echo "🔧 Correction complète des dépendances Maven..."

# 1. Nettoyer
rm -rf docker/
docker-compose down 2>/dev/null || true

# 2. Créer la structure
mkdir -p docker/mason docker/painter docker/gestioncarte

# 3. Créer le POM parent COMPLET avec toutes les versions des dépendances Mason
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

        <!-- Versions des dépendances tierces -->
        <mapstruct.version>1.6.0.Beta1</mapstruct.version>
        <swagger.version>2.2.21</swagger.version>
        <liquibase.version>4.27.0</liquibase.version>
        <jacoco.version>0.8.12</jacoco.version>
        <resilience4j.version>2.1.0</resilience4j.version>
        <dependency-check.version>8.4.3</dependency-check.version>
        <springdoc.version>2.2.0</springdoc.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <!-- Spring Boot BOM -->
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>3.2.5</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>

            <!-- Spring Cloud BOM -->
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>2023.0.1</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>

            <!-- SpringDoc OpenAPI BOM -->
            <dependency>
                <groupId>org.springdoc</groupId>
                <artifactId>springdoc-openapi</artifactId>
                <version>2.5.0</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>

            <!-- Mason Dependencies - TOUTES LES VERSIONS -->
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
                <artifactId>mason-localization</artifactId>
                <version>${mason.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.mason</groupId>
                <artifactId>mason-jpa</artifactId>
                <version>${mason.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.mason</groupId>
                <artifactId>mason-jpa-cache</artifactId>
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
                <artifactId>mason-transaction-author</artifactId>
                <version>${mason.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.mason</groupId>
                <artifactId>mason-kubernetes</artifactId>
                <version>${mason.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.mason</groupId>
                <artifactId>mason-web-client</artifactId>
                <version>${mason.version}</version>
            </dependency>
            <dependency>
                <groupId>com.pcagrade.mason</groupId>
                <artifactId>mason-test</artifactId>
                <version>${mason.version}</version>
                <scope>test</scope>
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

            <!-- Dépendances tierces -->
            <dependency>
                <groupId>org.mapstruct</groupId>
                <artifactId>mapstruct</artifactId>
                <version>${mapstruct.version}</version>
            </dependency>
            <dependency>
                <groupId>org.mapstruct</groupId>
                <artifactId>mapstruct-processor</artifactId>
                <version>${mapstruct.version}</version>
            </dependency>
            <dependency>
                <groupId>io.swagger.core.v3</groupId>
                <artifactId>swagger-annotations</artifactId>
                <version>${swagger.version}</version>
            </dependency>
            <dependency>
                <groupId>org.liquibase</groupId>
                <artifactId>liquibase-core</artifactId>
                <version>${liquibase.version}</version>
            </dependency>

            <!-- Resilience4j -->
            <dependency>
                <groupId>io.github.resilience4j</groupId>
                <artifactId>resilience4j-spring-boot2</artifactId>
                <version>${resilience4j.version}</version>
            </dependency>
            <dependency>
                <groupId>io.github.resilience4j</groupId>
                <artifactId>resilience4j-reactor</artifactId>
                <version>${resilience4j.version}</version>
            </dependency>
            <dependency>
                <groupId>io.github.resilience4j</groupId>
                <artifactId>resilience4j-ratelimiter</artifactId>
                <version>${resilience4j.version}</version>
            </dependency>
            <dependency>
                <groupId>io.github.resilience4j</groupId>
                <artifactId>resilience4j-timelimiter</artifactId>
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

    <build>
        <pluginManagement>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-compiler-plugin</artifactId>
                    <configuration>
                        <source>${java.version}</source>
                        <target>${java.version}</target>
                        <annotationProcessorPaths>
                            <path>
                                <groupId>org.mapstruct</groupId>
                                <artifactId>mapstruct-processor</artifactId>
                                <version>${mapstruct.version}</version>
                            </path>
                        </annotationProcessorPaths>
                    </configuration>
                </plugin>
                <plugin>
                    <groupId>org.jacoco</groupId>
                    <artifactId>jacoco-maven-plugin</artifactId>
                    <version>${jacoco.version}</version>
                </plugin>
            </plugins>
        </pluginManagement>
    </build>
</project>
EOF

# 4. Dockerfile Mason - Simplifié
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

# Build Mason avec le POM parent disponible
WORKDIR /usr/src/app/mason
RUN mvn clean install -DskipTests

# Image finale - Mason est une bibliothèque, pas une application
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -g 1000 appgroup && adduser -u 1000 -G appgroup -s /bin/sh -D appuser
USER appuser
EXPOSE 8083
CMD ["java", "-version"]
EOF

# 5. Dockerfile Painter - Avec dependencyManagement complet
cat > docker/painter/Dockerfile << 'EOF'
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /usr/src/app

# Copier et installer le POM parent cardmanager avec toutes les dépendances
COPY docker/cardmanager-parent.xml cardmanager-pom.xml
RUN mvn install:install-file \
    -Dfile=cardmanager-pom.xml \
    -DgroupId=com.pcagrade \
    -DartifactId=cardmanager \
    -Dversion=1.0.0-SNAPSHOT \
    -Dpackaging=pom

# Cloner et build Mason (dépendance de Painter)
RUN git clone --depth 1 --branch main https://github.com/ialame/mason.git mason
WORKDIR /usr/src/app/mason
RUN mvn clean install -DskipTests

# Cloner Painter
WORKDIR /usr/src/app
RUN git clone --depth 1 --branch main https://github.com/ialame/painter.git painter

# Build Painter avec toutes les dépendances Mason disponibles
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

# 6. Dockerfile GestionCarte
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

# Build Mason en premier (dépendance de Painter et GestionCarte)
RUN git clone --depth 1 --branch main https://github.com/ialame/mason.git mason
WORKDIR /usr/src/app/mason
RUN mvn clean install -DskipTests

# Build Painter en second (dépendance de GestionCarte)
WORKDIR /usr/src/app
RUN git clone --depth 1 --branch main https://github.com/ialame/painter.git painter
WORKDIR /usr/src/app/painter
RUN mvn clean install -DskipTests

# Build GestionCarte en dernier
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

# 7. Créer nginx-images.conf
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

# 8. Docker-compose.yml - Simplifié pour les services qui fonctionnent
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
echo "🎯 Correction complète des dépendances Maven !"
echo ""
echo "✅ Ce qui a été corrigé :"
echo "   - POM parent cardmanager avec TOUTES les versions Mason"
echo "   - dependencyManagement complet pour toutes les dépendances"
echo "   - Versions Resilience4j, MapStruct, Swagger correctes"
echo "   - Build séquentiel respectant les dépendances"
echo ""
echo "🚀 Maintenant, lancez :"
echo "   docker-compose build --no-cache"
echo "   docker-compose up -d"
echo ""
echo "⏳ Le build va prendre 15-20 minutes (compilation complète de tous les modules)..."
echo "📊 Services disponibles :"
echo "   - Application : http://localhost:8080"
echo "   - Painter : http://localhost:8081"
echo "   - Images : http://localhost:8082/images/"
echo "   - Base de données : localhost:3307"