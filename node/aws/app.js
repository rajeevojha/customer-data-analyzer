const express = require('express');
const redis = require('redis');
const app = express();
require ('dotenv').config();
const client = redis.createClient({
    username: 'default',
    password: process.env.REDIS_PASSWORD,
    socket: {
        host: process.env.REDIS_HOST,
        port: 13462
    }
});

client.on('error', err => console.log('Redis Client Error', err));

client.connect();


app.get('/', async (req, res) => {
  await client.incr('visits');
  const visits = await client.get('visits');
  res.send(`Hello World! Visits: ${visits}`);
});

app.listen(3000, () => console.log('Running on 3000'));
