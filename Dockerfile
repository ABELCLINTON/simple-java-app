# ---------- Build Stage ----------
# Use Maven with JDK 17 to build the app
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Set working directory
WORKDIR /app

# Copy pom.xml first and download dependencies (better caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the full source and build
COPY src ./src
RUN mvn clean package -DskipTests


# ---------- Run Stage ----------
# Use a smaller runtime image for running the app
FROM eclipse-temurin:17-jdk-jammy

# Set working directory
WORKDIR /app

# Copy built JAR file from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port (change if your app runs on another port)
EXPOSE 8080

# Command to run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
