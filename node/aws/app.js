const express = require('express');
const AWS = require('aws-sdk');
const app = express();

AWS.config.update({ region: 'us-west-1'});


const dynamodb = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = 'MyDynamoTable';

app.get('/', (req, res) => res.send('Hello World from Customer Data Analyzer!'));

app.get('/users', async (req, res) => {
  try {
    const params = { TableName: TABLE_NAME };
    const data = await dynamodb.scan(params).promise();
    res.json(data.Items);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).send('Error fetching users');
  }
});

app.use(express.json());
app.post('/users', async (req, res) => {
  const { id, name, activity } = req.body; // Expect JSON body
  if (!id || !name) return res.status(400).send('Missing id or name');
  try {
    const params = {
      TableName: TABLE_NAME,
      Item: { id, name, activity }
    };
    await dynamodb.put(params).promise();
    res.status(201).json(params.Item);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).send('Error creating user');
  }
});

// PUT update user by id
app.use(express.json());
app.put('/users/:id', async (req, res) => {
  const { id } = req.params;
  const { name, activity } = req.body;
  try {
    const params = {
      TableName: TABLE_NAME,
      Key: { id },
      UpdateExpression: 'set #n = :name, #a = :activity',
      ExpressionAttributeNames: { '#n': 'name', '#a': 'activity' },
      ExpressionAttributeValues: { ':name': name, ':activity': activity },
      ReturnValues: 'ALL_NEW'
    };
    const data = await dynamodb.update(params).promise();
    res.json(data.Attributes);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).send('Error updating user');
  }
});

// DELETE user by id
app.use(express.json());
app.delete('/users/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const params = {
      TableName: TABLE_NAME,
      Key: { id }
    };
    await dynamodb.delete(params).promise();
    res.status(204).send(); // No content on success
  } catch (error) {
    console.error('Error:', error);
    res.status(500).send('Error deleting user');
  }
});

app.get('/stats', async (req, res) => {
  try {
    const params = { TableName: TABLE_NAME };
    const data = await dynamodb.scan(params).promise();
    const users = data.Items;

    // Aggregate by activity
    const stats = users.reduce((acc, user) => {
      const activity = user.activity || 'unknown';
      acc[activity] = (acc[activity] || 0) + 1;
      return acc;
    }, {});

    res.json(stats);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).send('Error fetching stats');
  }
});
app.listen(3000, '0.0.0.0', () => console.log('Server running on port 3000'));


