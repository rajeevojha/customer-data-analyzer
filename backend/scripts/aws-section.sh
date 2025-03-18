#!/bin/bash
echo "aws setup start $(date)" >> /var/log/startup.log
curl https://sdk.cloud.google.com | bash -s -- --disable-prompts >> /var/log/startup.log 2>&1
source ~/.bashrc
#aws cp s3://customer-data-training-ro/node/aws/app.js /home/ubuntu/app.js >> /var/log/startup.log 2>&1
echo "aws setup done" >> /var/log/startup.log
