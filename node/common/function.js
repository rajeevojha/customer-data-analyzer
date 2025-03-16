const redis = require('redis');

async function hitCounter(source) {
  const client = redis.createClient({
      console.log(`Connecting to ${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`);
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
  const source = event.source || 'gcp';
  const score = await hitCounter(source);
  return { statusCode: 200, body: `${source} Score: ${score}` };
};

// Local run (Docker, GCP)
if (require.main === module) {
  const source = process.argv[2] || 'docker';
  setInterval(async () => {
    const score = await hitCounter(source);
    console.log(`${source} Score: ${score}`);
  }, parseInt(process.argv[3]) || 2000);
}
