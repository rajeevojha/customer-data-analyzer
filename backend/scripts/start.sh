#!/bin/bash
get_ip() {
  IP=$(curl -s ifconfig.me)
  if [ -z "$IP" ]; then
    IP=$(curl -s ipinfo.io/ip)
  fi
  if [ -z "$IP" ]; then
    echo "Failed to get IP" >&2
    exit 1
  fi
  echo "$IP"
}

WINDOWS_FILE="/mnt/c/Users/rajeev/downloads/users.csv"  # Adjust path
WSL_FILE="/home/rajeev/customer-data-analyzer/users.csv"
cp "$WINDOWS_FILE" "$WSL_FILE"

#copy the script files to cloud
gcloud storage cp -R /home/rajeev/customer-data-analyzer/scripts gs://customer-data-training-ro/scripts

#gcloud storage cp -R /home/rajeev/customer-data-analyzer/data gs://customer-data-training-ro/data
gsutil -m rsync -rd /home/rajeev/customer-data-analyzer/data gs://customer-data-training-ro/data
# Upload to S3
aws s3 sync /home/rajeev/customer-data-analyzer/scripts s3://customer-data-training-ro/scripts
aws s3 sync /home/rajeev/customer-data-analyzer/data/ s3://customer-data-training-ro/data
#
#Run Terraform
#
cd /home/rajeev/customer-data-analyzer/infra/terraform
MY_IP=$(get_ip)
TF_LOG=DEBUG terraform apply -var "my_ip=$MY_IP" -auto-approve > terraform.log 2>&1
