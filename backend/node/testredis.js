import redis from 'redis';
(async () => { const client = redis.createClient(
   { socket: { host: process.env.REDIS_HOST, port: 13462 }, 
               password: 's9uIXYMcPdkTnru9sMcacpx8o7JL48lm' }); 
 await client.connect(); 
 console.log('Connected'); 
 await client.quit(); })();
