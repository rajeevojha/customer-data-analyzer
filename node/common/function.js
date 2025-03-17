const redis = require('redis');

async function hitCounter(source) {
  const client = redis.createClient({
      username: process.env.REDIS_USER||'default',
      password: process.env.REDIS_PASSWORD||'',
      socket: {
          host: process.env.REDIS_HOST||'redis-local',
          port: parseInt(process.env.REDIS_PORT) || 6379
      }
  });
  //const client = redis.createClient({ url: 'redis://host.docker.internal:6379' });
  await client.connect();
  await client.incr('hits');
  const sourceHits = await client.hIncrBy('source_hits', source, 1);
  const totalHits = await client.get('hits');
  const score = sourceHits * totalHits;
  await client.hSet('scores', source, score);
  await client.quit();
  return score;
}

// Lambda handler
exports.handler = async (event) => {
  const message = event.data
   ? JSON.parse(Buffer.from(event.data, 'base64').toString())
   : {};
  const source = message.source || 'aws';
  const score = await hitCounter(source);
  return { statusCode: 200, body: `${source} Score: ${score}` };
};

if (require.main === module) {
  const source = process.argv[2] || 'docker';
  const interval = parseInt(process.argv[3]) || 2000;
  console.log(`Starting ${source} with interval ${interval}ms`);
  setInterval(async () => {
    try {
      const score = await hitCounter(source);
      console.log(`${source} Score: ${score}`);
    } catch (e) {
      console.error(`Error: ${e.message}`);
    }
  }, interval);
  process.on('SIGTERM', () => process.exit(0));
}// Local run (Docker, GCP)
