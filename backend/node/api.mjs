import redis from 'redis';
console.log('REDIS_HOST:', process.env.REDIS_HOST);
console.log('REDIS_USER:', process.env.REDIS_USER);
const client = redis.createClient({
   username: process.env.REDIS_USER || 'default',
   password: process.env.REDIS_PASSWORD || 'm',
   socket: {
     host: process.env.REDIS_HOST || '-cloud.com',
     port: parseInt(process.env.REDIS_PORT) || 13462
   }
 });

await client.connect();

export async function handler(event) {
  const { httpMethod, path, body } = event;
  const headers = { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' };  // CORS

  if (httpMethod === 'GET' && path === '/scores') {
    try {
      const scores = await client.hGetAll('scores');
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
          aws: scores.aws || 0,
          gcp: scores.gcp || 0,
          docker: scores.docker || 0
        })
      };
    } catch (err) {
      return { statusCode: 500, headers, body: JSON.stringify({ error: 'Failed to fetch scores' }) };
    }
  }

  if (httpMethod === 'POST' && path === '/hit') {
    const { source } = JSON.parse(body || '{}');
    if (!source) return { statusCode: 400, headers, body: JSON.stringify({ error: 'Source required' }) };

    try {
      await client.incr('hits');
      const sourceHits = await client.hIncrBy('source_hits', source, 1);
      const totalHits = await client.get('hits');
      const score = sourceHits * totalHits;
      await client.hSet('scores', source, score);
      return { statusCode: 200, headers, body: JSON.stringify({ source, score }) };
    } catch (err) {
      return { statusCode: 500, headers, body: JSON.stringify({ error: 'Failed to hit' }) };
    }
  }

  return { statusCode: 404, headers, body: JSON.stringify({ error: 'Not found' }) };
}
