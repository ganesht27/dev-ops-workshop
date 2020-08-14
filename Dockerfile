FROM openjdk:11.0.8-jdk as build
WORKDIR /workspace/application
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src
RUN chmod +x ./mvnw && ./mvnw install -DskipTests

FROM openjdk:11-jre-slim as builder
WORKDIR application
COPY --from=build /workspace/application/target/*.jar application.jar
RUN ls -lrt
RUN java -Djarmode=layertools -jar application.jar extract

FROM openjdk:11-jre-slim
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
