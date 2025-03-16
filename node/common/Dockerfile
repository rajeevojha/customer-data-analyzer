FROM node:18-slim
WORKDIR /app
COPY node/common/package.json node/common/app.js ./
RUN npm install redis
CMD ["node", "app.js", "docker", "2000"]
