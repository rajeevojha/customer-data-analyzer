const express = require('express');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const app = express();
app.use(express.json());

const pool = new Pool({
  user: 'postgres',
  host: 'customers.c9sa2ks60dfr.us-west-1.rds.amazonaws.com',
//  host: '34.83.253.65',
  database: 'customers',
  password: 'Sw33t0Rang3',
  port: 5432,
  ssl: { rejectUnauthorized: false } // Add SSL, skip cert check for now
});

const JWT_SECRET = 'your-secret-key';

const authMiddleware = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).send('No token');
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).send('Invalid token');
    req.user = decoded;
    next();
  });
};

app.post('/login', (req, res) => {
  const { username } = req.body;
  if (!username) return res.status(400).send('Missing username');
  const token = jwt.sign({ username }, JWT_SECRET, { expiresIn: '1h' });
  res.json({ token });
});

app.get('/users', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users');
    res.json(result.rows);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).send('Error fetching users');
  }
});

app.listen(3000, '0.0.0.0', () => console.log('Server running on port 3000'));

