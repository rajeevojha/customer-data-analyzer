#!/bin/bash
set -e  # Exit—error

echo "Starting—Centralized DB Setup"

# Vars
ROOT_DIR="$HOME/customer-data-analyzer"
BRANCH="centralized-db"
API_PORT=3001
VUE_PORT=8080

# 1. Checkout—centralized-db
cd "$ROOT_DIR"
git checkout "$BRANCH"
echo "On branch—$BRANCH"

# 2. Terraform—Apply
cd "$ROOT_DIR/backend/infra/terraform"
terraform init
terraform apply -auto-approve
echo "Terraform—deployed"

# 3. Node API—Start
cd "$ROOT_DIR/backend/node"
npm install &>/dev/null
node --es-module-specifier-resolution=node api.mjs 
sleep 2  # Wait—API up
echo "Node API—running—http://localhost:$API_PORT"

# 4. AWS Step Functions—Trigger
SFN_ARN=$(aws stepfunctions list-state-machines --query "stateMachines[?name=='redis_counter_game'].stateMachineArn" --output text)
if [ -n "$SFN_ARN" ]; then
  aws stepfunctions start-execution --state-machine-arn "$SFN_ARN" --input '{"time": 0}'
  echo "AWS Step Functions—triggered—$SFN_ARN"
else
  echo "Error: Step Functions ARN—not found"
  exit 1
fi

# 5. Vue UI—Start (optional—uncomment)
# cd "$ROOT_DIR/ui/vue"
# npm install &>/dev/null
# npm run serve &  # Background
# echo "Vue UI—running—http://localhost:$VUE_PORT"

echo "Setup—complete! Check scores:"
echo "  - API: curl http://localhost:$API_PORT/scores"
echo "  - AWS: aws logs tail /aws/lambda/redis_counter"
echo "  - GCP: gcloud functions logs read redis-counter"
echo "  - Docker: docker logs redis-app"
# echo "  - UI: http://localhost:$VUE_PORT"
