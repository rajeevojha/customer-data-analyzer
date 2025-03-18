const express = require('express');
require ('dotenv').config();
const redis = require('redis');
const app = express();
const cors = require('cors');

app.use(cors());

const client = redis.createClient({
   username: process.env.REDIS_USER || 'default',
   password: process.env.REDIS_PASSWORD || '',
   socket: {
     host: process.env.REDIS_HOST || 'redis-local',
     port: parseInt(process.env.REDIS_PORT) || 6379
   }
 });
(async () => {
   try {
       await client.connect();
       console.log("redis connected ");
       }catch (err) {
        console.error("failed connection");
       console.log (process.env.REDIS_HOST);
       console.log (process.env.REDIS_USER);
      }
})();
// Async API endpoint
app.get('/scores', async (req, res) => {
  try {
    const scores = await client.hGetAll('scores');
    res.json({
      aws: scores.aws || 0,
      gcp: scores.gcp || 0,
      docker: scores.docker || 0
    });
  } catch (err) {
    console.error('Redis fetch error:', err);
    res.status(500).json({ error: 'Failed to fetch scores' });
  }
});
app.listen(3001, () => console.log('API at http://localhost:3001'));
