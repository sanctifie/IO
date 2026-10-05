# Dockerfile de production (projet 13) : build multi-stage, servi par Nginx en utilisateur non-root.
# L'original (Dockerfile.original) lançait le serveur de DÉVELOPPEMENT (npm start) dans une image ~1 Go.

# Étape 1 : construire les fichiers statiques
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY . .
RUN npm run build

# Étape 2 : les servir avec Nginx, sans Node, sans sources, sans node_modules
FROM nginxinc/nginx-unprivileged:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html
# l'image "unprivileged" tourne avec l'utilisateur nginx (UID 101) et écoute sur 8080
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:8080/ >/dev/null || exit 1
