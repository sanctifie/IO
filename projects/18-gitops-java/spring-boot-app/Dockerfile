# adoptopenjdk/openjdk11 (image d'origine) n'est plus maintenue : eclipse-temurin est son successeur
FROM eclipse-temurin:11-jre
ARG artifact=target/spring-boot-web.jar
WORKDIR /opt/app
COPY ${artifact} app.jar
RUN useradd -r app
USER app
ENTRYPOINT ["java", "-jar", "app.jar"]
