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
