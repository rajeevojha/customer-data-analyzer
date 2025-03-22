#!/bin/bash
echo "Run start $(date)" >> /var/log/startup.log
mkdir -p /home/ubuntu/app
mv /home/ubuntu/app.js /home/ubuntu/app/app.js
cd /home/ubuntu/app
npm install express  dotenv redis >> /var/log/startup.log 2>&1
sudo bash -c "cat << SERVICE > /etc/systemd/system/node-app.service
[Unit]
Description=Node Hello World
After=network.target
[Service]
ExecStart=/usr/bin/node /home/ubuntu/app/app.js
Restart=always
User=ubuntu
WorkingDirectory=/home/ubuntu/app
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
[Install]
WantedBy=multi-user.target
SERVICE"
sudo systemctl enable node-app.service >> /var/log/startup.log 2>&1
sudo systemctl start node-app.service >> /var/log/startup.log 2>&1
sleep 5
ps -ef | grep node >> /var/log/startup.log 2>&1
netstat -tuln | grep 3000 >> /var/log/startup.log 2>&1
echo "Run done $(date)" >> /var/log/startup.log
