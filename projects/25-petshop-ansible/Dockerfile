# Multi-stage : on compile avec Maven, on n'embarque que le .war dans un Tomcat (JRE seul).
# (L'original partait de l'image dépréciée openjdk:17.0.2, recompilait tout et lançait Tomcat via Cargo.)
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY .mvn .mvn
COPY mvnw pom.xml format.xml LICENSE_HEADER ./
RUN mvn -B -q dependency:go-offline -Dlicense.skip=true || true
COPY src src
# license.skip : le plugin de licences exige un dépôt Git, absent dans le contexte de build Docker
RUN mvn -B clean package -DskipTests -Dlicense.skip=true

FROM tomcat:9.0-jre17
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/jpetstore.war /usr/local/tomcat/webapps/jpetstore.war
EXPOSE 8080
# http://<hôte>:8080/jpetstore
