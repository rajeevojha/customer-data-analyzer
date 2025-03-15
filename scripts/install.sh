#!/bin/bash
sudo touch /var/log/startup.log
sudo chmod 666 /var/log/startup.log
echo "*******************Common install start $(date)****************" | sudo tee -a /var/log/startup.log
sudo DEBIAN_FRONTEND=noninteractive apt update >> /var/log/startup.log 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt install -y redis-tools  >> /var/log/startup.log 2>&1
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - >> /var/log/startup.log 2>&1
sudo apt install -y nodejs >> /var/log/startup.log 2>&1
sudo sh -c echo "Node: $(node -v)" >> /var/log/startup.log
sudo sh -c echo "Common install done" >> /var/log/startup.log
