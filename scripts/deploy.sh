#!/bin/bash

set -e

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566

echo "Deploying SQS..."
docker run --rm -v "$PWD":"$PWD" -w "$PWD" \
  -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  -e AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION" \
  amazon/aws-cli \
  cloudformation create-stack \
  --stack-name sqs-stack \
  --template-body file://infra/cloudformation/sqs.yml \
  --endpoint-url http://host.docker.internal:4566 \
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
  --endpoint-url http://host.docker.internal:4566 \
  --region us-east-1
