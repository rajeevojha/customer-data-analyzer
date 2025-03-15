#!/bin/bash
echo "Run start $(date)" >> /var/log/startup.log
mkdir -p /home/ubuntu/app
mv /home/ubuntu/app.js /home/ubuntu/app/app.js
cd /home/ubuntu/app
npm install express  dotenv redis >> /var/log/startup.log 2>&1
node app.js >>/tmp/run.log 2>&1 || echo "node failed" >>/tmp/run.log &
echo "Run done $(date)" >> /var/log/startup.log
