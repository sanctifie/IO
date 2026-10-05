# Le .jar est construit par Maven dans le pipeline (stage "Build"), puis copié ici.
# JRE seul (pas de JDK) et utilisateur non-root.
FROM eclipse-temurin:17-jre-alpine
RUN addgroup -S app && adduser -S app -G app
WORKDIR /usr/src/app
COPY target/*.jar app.jar
USER app
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
