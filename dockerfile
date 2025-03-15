FROM node:18-slim
WORKDIR /app
COPY node/aws/app.js node/aws/package.json  ./
COPY data/ ./data/

RUN npm install express redis dotenv
EXPOSE 3000
CMD ["node", "app.js"]
