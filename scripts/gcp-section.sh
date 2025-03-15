#!/bin/bash
echo "GCP setup start $(date)" >> /var/log/startup.log
curl https://sdk.cloud.google.com | bash -s -- --disable-prompts >> /var/log/startup.log 2>&1
source ~/.bashrc
gcloud config set project  carbide-ether-452420-i7 >> /var/log/startup.log 2>&1
#gsutil cp gs://customer-data-training-ro/scripts/app.js /home/ubuntu/app.js >> /var/log/startup.log 2>&1
echo "GCP setup done" >> /var/log/startup.log
