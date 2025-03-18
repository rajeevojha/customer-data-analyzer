const redis = require('redis');

exports.handler = async (event) => {
  const client = redis.createClient({
      username: 'default',
      password: process.env.REDIS_PASSWORD,
      socket: {
          host: process.env.REDIS_HOST,
          port: 13462
      }
  });
  await client.connect();
  const count = await client.incr('game_counter');
  await client.quit();
  return { statusCode: 200, body: `Lambda Count: ${count}` };
};
