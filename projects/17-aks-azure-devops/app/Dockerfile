# centos:centos7 (image d'origine) est en fin de vie : ses dépôts yum ont fermé, le build échoue.
FROM node:20-alpine
WORKDIR /src
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
USER node
EXPOSE 8888
CMD ["node", "app.js"]
