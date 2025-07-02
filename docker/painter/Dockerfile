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
