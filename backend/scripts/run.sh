#!/bin/bash
echo "Run start $(date)" >> /var/log/startup.log
mkdir -p /home/ubuntu/app
mv /home/ubuntu/app.js /home/ubuntu/app/app.js
ls -l /home/ubuntu/app >>/tmp/run.log
cd /home/ubuntu/app
cat /home/ubuntu/app/.env >>/tmp/run.log 2>&1 || echo ".env missing" >>/tmp/run.log
npm install express  dotenv redis >> /var/log/startup.log 2>&1
node app.js >>/tmp/run.log 2>&1 || echo "node failed" >>/tmp/run.log &
echo "Run done $(date)" >> /var/log/startup.log
