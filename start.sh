#!/bin/bash
set -e  # Exit—error

echo "Starting—Centralized DB Setup"

# Vars
ROOT_DIR="$HOME/customer-data-analyzer"
BRANCH="master"

# 1. Checkout—master branch
cd "$ROOT_DIR"
git checkout "$BRANCH"
echo "On branch—$BRANCH"

# 2. Terraform—Apply
cd "$ROOT_DIR/backend/infra/terraform"
terraform init > terraform_init.log 2>&1
terraform apply -auto-approve > terraform_apply.log 2>&1
echo "Terraform—deployed - logs in terrafor_apply.log"

# 3. AWS Step Functions—Trigger
SFN_ARN=$(aws stepfunctions list-state-machines --query "stateMachines[?name=='redis_counter_game'].stateMachineArn" --output text)
if [ -n "$SFN_ARN" ]; then
  aws stepfunctions start-execution --state-machine-arn "$SFN_ARN" --input '{"time": 0}' > /dev/null 2>&1
  echo "AWS Step Functions—triggered—$SFN_ARN"
else
  echo "Error: Step Functions ARN—not found"
  exit 1
fi
# 4. start git action
git add .
git commit -m "updated .env.local value for api"
git push origin "$branch"

echo "Setup—complete! Check scores:"
echo "  - AWS: aws logs tail /aws/lambda/redis_counter"
echo "  - GCP: gcloud functions logs read redis-counter"
echo "  - Docker: docker logs redis-app"
echo "  - Vue EB: http://vueappenv.eba-mwdr92mw.us-west-1.elasticbeanstalk.com/"
