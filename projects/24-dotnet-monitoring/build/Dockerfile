# =======================================================
# Étape 1 - compiler l'application (SDK .NET 8 LTS ; .NET 6 d'origine en fin de support)
# =======================================================
ARG IMAGE_BASE=8.0-alpine

FROM mcr.microsoft.com/dotnet/sdk:$IMAGE_BASE AS build
WORKDIR /build
COPY src ./src
WORKDIR /build/src
RUN dotnet restore
RUN dotnet publish --no-restore --configuration Release --output /publish

# =======================================================
# Étape 2 - image d'exécution (runtime ASP.NET seul)
# =======================================================
FROM mcr.microsoft.com/dotnet/aspnet:$IMAGE_BASE

LABEL org.opencontainers.image.title=".NET Core Demo Web App" \
      org.opencontainers.image.version="1.5.0" \
      org.opencontainers.image.source="https://github.com/benc-uk/dotnet-demoapp"

WORKDIR /app
COPY --from=build /publish .

EXPOSE 5000
ENV ASPNETCORE_URLS=http://+:5000 \
    ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_FORWARDEDHEADERS_ENABLED=true

# Utilisateur non-root fourni par les images .NET 8 (UID 1654)
USER $APP_UID

# Forme "exec" : dotnet reçoit directement les signaux (arrêt propre du conteneur)
ENTRYPOINT ["dotnet", "dotnet-demoapp.dll"]
