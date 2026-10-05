# Image de production Next.js (l'original lançait "npm run dev", le serveur de développement,
# sur node:19 — version impaire, jamais LTS, en fin de vie).
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY . .
# Next 12 utilise un algorithme de hachage retiré d'OpenSSL 3 (Node >= 17)
ENV NODE_OPTIONS=--openssl-legacy-provider NEXT_TELEMETRY_DISABLED=1
# .env.production (copié par le pipeline depuis un credential Jenkins) est lu ici
RUN test -f .env.production || { echo "ERREUR : .env.production manquant (config Firebase, voir .env.example)"; exit 1; }
RUN npm run build && npm prune --omit=dev

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 NODE_OPTIONS=--openssl-legacy-provider
COPY --from=build --chown=node:node /app/package.json ./
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/.next ./.next
COPY --from=build --chown=node:node /app/public ./public
COPY --from=build --chown=node:node /app/next.config.js ./
USER node
EXPOSE 3000
CMD ["npx", "next", "start", "-p", "3000"]
