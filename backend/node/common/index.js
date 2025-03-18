import fetch from 'node-fetch';

async function hitCounter(source) {
  const response = await fetch('http://localhost:3001/hit', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ source })
  });
  const data = await response.json();
  return data.score;
}
export async function handler(event) {
  const message = event.data ? JSON.parse(Buffer.from(event.data, 'base64').toString()) : {};
  const source = message.source || 'aws';
  const score = await hitCounter(source);
  return { statusCode: 200, body: `${source} Score: ${score}` };
};
if (import.meta.url === `file://${process.argv[1]}`) {
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
