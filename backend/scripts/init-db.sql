CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100),
  activity VARCHAR(100)
);
\copy users(id,name,activity) FROM '/home/ubuntu/app/users.csv' WITH (FORMAT CSV, HEADER);
