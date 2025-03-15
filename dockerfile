FROM node:18-slim
WORKDIR /app
COPY package.json app.js ./
COPY data/ ./data/ # add the data folder
RUN npm install express redis dotenv
EXPOSE 3000
CMD ["node", "app.js"]
