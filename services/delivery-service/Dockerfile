FROM ballerina/ballerina:2201.8.0 AS build
WORKDIR /home/ballerina
COPY --chown=ballerina:ballerina . .
RUN bal build

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /home/ballerina/target/bin/*.jar app.jar
EXPOSE 9097
ENTRYPOINT ["java", "-jar", "app.jar"]