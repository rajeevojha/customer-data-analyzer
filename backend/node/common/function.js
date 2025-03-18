const fetch = require('node-fetch');
//const redis = require('redis');

/* async function hitCounter(source) {
  const client = redis.createClient({
    username: process.env.REDIS_USER || 'default',
    password: process.env.REDIS_PASSWORD || '',
    socket: {
      host: process.env.REDIS_HOST || 'redis-local',
      port: parseInt(process.env.REDIS_PORT) || 6379
    }
  });
  await client.connect();

  // Check if new game—first hit
  const hits = await client.get('hits') || 0;
  if (hits === 0) {
    await client.set('hits', 0);  // Ensure initialized
    await client.hSet('scores', source, 0);  // Start at 0
    await client.hIncrBy('source_hits', source, 1);
    await client.incr('hits');
    await client.quit();
    return 0;
  }

  // Normal hit
  await client.incr('hits');
  const sourceHits = await client.hIncrBy('source_hits', source, 1);
  const totalScore = await client.hGetAll('scores').then(scores => 
    Object.values(scores).reduce((sum, val) => sum + parseInt(val || 0), 0)
  );
  const score = (sourceHits * totalScore) + 1;
  await client.hSet('scores', source, score);
  await client.quit();
  return score;
}
*/
async function hitCounter(source) {
  const response = await fetch('http://localhost:3001/hit', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ source })
  });
  const data = await response.json();
  return data.score;
}
exports.handler = async (event) => {
  const message = event.data ? JSON.parse(Buffer.from(event.data, 'base64').toString()) : {};
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
}
