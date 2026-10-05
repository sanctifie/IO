# Node 20 LTS (node:19 d'origine : version impaire, en fin de vie), utilisateur non-root.
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./

FROM base AS dependencies
RUN npm ci --no-audit --no-fund

FROM dependencies AS build
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

# dépendances de production seulement pour l'image finale
FROM base AS prod-deps
RUN npm ci --omit=dev --no-audit --no-fund

FROM node:20-alpine AS production
WORKDIR /app
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1
COPY --from=prod-deps --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/.next ./.next
COPY --from=build --chown=node:node /app/public ./public
COPY --from=build --chown=node:node /app/package*.json ./
COPY --from=build --chown=node:node /app/next.config.js ./next.config.js
COPY --from=build --chown=node:node /app/next-i18next.config.js ./next-i18next.config.js
USER node
EXPOSE 3000
# OPENAI_API_KEY est fournie à l'exécution (variable d'environnement / Secret Kubernetes), jamais dans l'image
CMD ["npm", "start"]
