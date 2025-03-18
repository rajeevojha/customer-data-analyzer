FROM node:18-slim
WORKDIR /app
COPY node/common/package.json node/common/function.js ./
RUN npm install redis
CMD ["node", "function.js", "docker", "2000"]
