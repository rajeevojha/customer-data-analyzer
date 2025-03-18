import express from 'express';
import redis from 'redis';
import cors from 'cors'
import "dotenv/config.js";

const app = express();

app.use(cors());
app.use(express.json());

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

app.post('/hit', async (req, res) => {
  const { source } = req.body;  // { "source": "aws" }
  if (!source) return res.status(400).json({ error: 'Source required' });

  try {
    await client.incr('hits');
    const sourceHits = await client.hIncrBy('source_hits', source, 1);
    const totalHits = await client.get('hits');
    const score = sourceHits * totalHits;  // Keep—your logic—tweak later
    await client.hSet('scores', source, score);
    res.json({ source, score });
  } catch (err) {
    console.error('Hit error:', err);
    res.status(500).json({ error: 'Failed to hit' });
  }
});
app.listen(3001, () => console.log('API at http://localhost:3001'));
