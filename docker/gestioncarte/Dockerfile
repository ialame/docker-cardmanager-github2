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
