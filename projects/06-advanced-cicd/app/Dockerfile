# openjdk:8 (image d'origine) est dépréciée et retirée : eclipse-temurin est son successeur
FROM eclipse-temurin:8-jre
WORKDIR /app
COPY jarstaging/com/satish/demo-workshop/2.1.2/demo-workshop-2.1.2.jar app.jar
RUN useradd -r app
USER app
EXPOSE 8000
ENTRYPOINT ["java", "-jar", "app.jar"]
