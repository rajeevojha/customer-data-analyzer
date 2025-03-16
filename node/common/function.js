const redis = require('redis');

async function hitCounter(source) {
  const client = redis.createClient({
      username: process.env.REDIS_USER,
      password: process.env.REDIS_PASSWORD,
      socket: {
          host: process.env.REDIS_HOST,
          port: process.env.REDIS_PORT
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
  const score = await hitCounter('aws');
  return { statusCode: 200, body: `AWS Score: ${score}` };
};

// Local run (Docker, GCP)
if (require.main === module) {
  const source = process.argv[2] || 'docker';
  setInterval(async () => {
    const score = await hitCounter(source);
    console.log(`${source} Score: ${score}`);
  }, parseInt(process.argv[3]) || 2000);
}
