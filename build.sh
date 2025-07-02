#!/bin/bash
echo "🏗️ Construction complète de CardManager depuis GitHub..."

# Variables de configuration
MASON_REPO_URL="https://github.com/ialame/mason"
PAINTER_REPO_URL="https://github.com/ialame/painter"
GESTIONCARTE_REPO_URL="https://github.com/ialame/gestioncarte"
MASON_BRANCH="main"
PAINTER_BRANCH="main"
GESTIONCARTE_BRANCH="main"

# Fonction pour vérifier les prérequis
check_prerequisites() {
    echo "🔍 Vérification des prérequis..."

    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker n'est pas installé"
        echo "💡 Installez Docker Desktop depuis https://www.docker.com/products/docker-desktop"
        exit 1
    fi

    # Vérifier Docker Compose
    if ! docker compose version &> /dev/null && ! docker-compose --version &> /dev/null; then
        echo "❌ Docker Compose n'est pas disponible"
        exit 1
    fi

    # Vérifier Git
    if ! command -v git &> /dev/null; then
        echo "❌ Git n'est pas installé"
        echo "💡 Installez Git depuis https://git-scm.com/"
        exit 1
    fi

    # Vérifier la connexion internet
    if ! ping -c 1 github.com &> /dev/null; then
        echo "❌ Pas de connexion à GitHub"
        echo "💡 Vérifiez votre connexion internet"
        exit 1
    fi

    echo "✅ Prérequis validés"
}

# Fonction pour créer les Dockerfiles
create_dockerfiles() {
    echo "📝 Création des Dockerfiles..."

    # Créer la structure des dossiers
    mkdir -p docker/mason docker/painter docker/gestioncarte

    # Dockerfile Mason
    cat > docker/mason/Dockerfile << 'EOF'
# Dockerfile pour Mason - Build depuis GitHub
FROM maven:3.9.6-eclipse-temurin-21 AS builder

# Arguments de build
ARG MASON_REPO_URL=https://github.com/ialame/mason
ARG PAINTER_REPO_URL=https://github.com/ialame/painter
ARG GESTIONCARTE_REPO_URL=https://github.com/ialame/gestioncarte
ARG MASON_BRANCH=main
ARG PAINTER_BRANCH=main
ARG GESTIONCARTE_BRANCH=main

WORKDIR /usr/src/app

# Cloner les dépôts
RUN git clone --depth 1 --branch ${MASON_BRANCH} ${MASON_REPO_URL} mason
RUN git clone --depth 1 --branch ${PAINTER_BRANCH} ${PAINTER_REPO_URL} painter
RUN git clone --depth 1 --branch ${GESTIONCARTE_BRANCH} ${GESTIONCARTE_REPO_URL} gestioncarte

# Créer le POM parent
RUN cat > pom.xml << 'POM_EOF'
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
    </modules>
</project>
POM_EOF

# Build Mason
RUN mvn clean install -DskipTests

# Image finale
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -g 1000 appgroup && adduser -u 1000 -G appgroup -s /bin/sh -D appuser
USER appuser
CMD ["java", "-version"]
EOF

    # Dockerfile Painter
    cat > docker/painter/Dockerfile << 'EOF'
# Dockerfile pour Painter - Build depuis GitHub
FROM maven:3.9.6-eclipse-temurin-21 AS builder

# Arguments de build
ARG MASON_REPO_URL=https://github.com/ialame/mason
ARG PAINTER_REPO_URL=https://github.com/ialame/painter
ARG GESTIONCARTE_REPO_URL=https://github.com/ialame/gestioncarte
ARG MASON_BRANCH=main
ARG PAINTER_BRANCH=main
ARG GESTIONCARTE_BRANCH=main

WORKDIR /usr/src/app

# Cloner les dépôts
RUN git clone --depth 1 --branch ${MASON_BRANCH} ${MASON_REPO_URL} mason
RUN git clone --depth 1 --branch ${PAINTER_BRANCH} ${PAINTER_REPO_URL} painter

# Créer le POM parent
RUN cat > pom.xml << 'POM_EOF'
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
    </modules>
</project>
POM_EOF

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

    # Dockerfile GestionCarte
    cat > docker/gestioncarte/Dockerfile << 'EOF'
# Dockerfile pour GestionCarte - Build depuis GitHub
FROM maven:3.9.6-eclipse-temurin-21 AS builder

# Arguments de build
ARG MASON_REPO_URL=https://github.com/ialame/mason
ARG PAINTER_REPO_URL=https://github.com/ialame/painter
ARG GESTIONCARTE_REPO_URL=https://github.com/ialame/gestioncarte
ARG MASON_BRANCH=main
ARG PAINTER_BRANCH=main
ARG GESTIONCARTE_BRANCH=main

WORKDIR /usr/src/app

# Cloner les dépôts
RUN git clone --depth 1 --branch ${MASON_BRANCH} ${MASON_REPO_URL} mason
RUN git clone --depth 1 --branch ${PAINTER_BRANCH} ${PAINTER_REPO_URL} painter
RUN git clone --depth 1 --branch ${GESTIONCARTE_BRANCH} ${GESTIONCARTE_REPO_URL} gestioncarte

# Créer le POM parent
RUN cat > pom.xml << 'POM_EOF'
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
POM_EOF

# Build
RUN mvn clean install -DskipTests

# Image finale
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /usr/src/app/gestioncarte/target/retriever-*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
EOF

    echo "✅ Dockerfiles créés"
}

# Fonction pour créer la configuration Nginx
create_nginx_config() {
    echo "📝 Création de la configuration Nginx..."

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

    echo "✅ Configuration Nginx créée"
}

# Fonction principale
main() {
    echo "🚀 CardManager - Build automatique depuis GitHub"
    echo "================================================="

    check_prerequisites
    create_dockerfiles
    create_nginx_config

    echo ""
    echo "🏗️ Construction des images Docker..."
    echo "⏳ Cela peut prendre 10-15 minutes selon votre connexion..."

    # Build avec Docker Compose
    if command -v docker-compose &> /dev/null; then
        docker-compose build --no-cache
    else
        docker compose build --no-cache
    fi

    echo ""
    echo "🚀 Démarrage des services..."

    # Start avec Docker Compose
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d
    else
        docker compose up -d
    fi

    echo ""
    echo "⏳ Attente du démarrage des services..."
    sleep 30

    echo ""
    echo "📊 État des services :"
    if command -v docker-compose &> /dev/null; then
        docker-compose ps
    else
        docker compose ps
    fi

    echo ""
    echo "✅ Build et démarrage terminés !"
    echo ""
    echo "📡 URLs d'accès :"
    echo "   - Application : http://localhost:8080"
    echo "   - Images : http://localhost:8082/images/"
    echo ""
    echo "🔧 Commandes utiles :"
    echo "   - Arrêter : ./stop.sh"
    echo "   - Logs : docker-compose logs -f"
    echo "   - Redémarrer : ./stop.sh && ./start.sh"
}

# Exécuter le script principal
main "$@"