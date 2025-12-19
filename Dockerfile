FROM maven:3.9.6-amazoncorretto-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM amazoncorretto:17-alpine
WORKDIR /app
EXPOSE 80
COPY --from=builder /app/target/*.jar app.jar
CMD ["java", "-jar", "app.jar"]
