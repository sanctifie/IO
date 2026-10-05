# Dockerfile de production (multi-stage, non-root) — même port 3000 que le projet d'origine,
# pour ne rien changer à la task definition, aux target groups ni à l'appspec.
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY . .
# CRA transforme les avertissements en erreurs si CI=true : on construit en mode normal
ENV CI=false
RUN npm run build

FROM nginxinc/nginx-unprivileged:stable-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 3000
