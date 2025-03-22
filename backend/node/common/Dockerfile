FROM node:18-slim
WORKDIR /app
COPY node/common/package.json node/common/index.js ./
RUN npm install
CMD ["node", "index.js", "docker", "20000"]
