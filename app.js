const express = require('express');
const AWS = require('aws-sdk');
const app = express();

AWS.config.update({ region: 'us-west-1'});

/*AWS.config.update({ region: 'us-west-1',
   accessKeyId: 'AKIAQZFG5DYQDYNU5Y5I', // Replace with your Access Key ID
   secretAccessKey: '9QOfp/zilwNQ7STWqp16QQj0Xl80k2Tn0B+cHz3T'});
*/
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
app.listen(3000, '0.0.0.0', () => console.log('Server running on port 3000'));


