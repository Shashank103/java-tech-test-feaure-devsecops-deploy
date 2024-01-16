# Stage 1: Build the application
FROM openjdk:17.0.1-slim AS builder

WORKDIR /app

# Copy only the necessary files for Maven dependency resolution
COPY pom.xml .
COPY src ./src

# Build the application
RUN apt-get update && \
    apt-get install -y maven && \
    mvn clean install

# Expose the port your application will run on
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "target/tdd-supermarket-1.0.0-SNAPSHOT.jar"]