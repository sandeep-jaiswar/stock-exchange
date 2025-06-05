#!/bin/bash

set -e

echo "Deploying SQS..."
docker run --rm -v "$PWD":"$PWD" -w "$PWD" \
  -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  -e AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION" \
  amazon/aws-cli \
  cloudformation create-stack \
  --stack-name sqs-stack \
  --template-body file://infra/cloudformation/sqs.yml \
  --endpoint-url $ENDPOINT_URL \
  --region us-east-1

echo "Deploying RDS..."
docker run --rm -v "$PWD":"$PWD" -w "$PWD" \
  -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  -e AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION" \
  amazon/aws-cli \
  cloudformation create-stack \
  --stack-name rds-stack \
  --template-body file://infra/cloudformation/rds.yml \
  --endpoint-url $ENDPOINT_URL \
  --region us-east-1
