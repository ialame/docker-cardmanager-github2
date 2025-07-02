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
