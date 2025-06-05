#!/bin/bash

set -e

# Default LocalStack endpoint if not passed
ENDPOINT_URL="${ENDPOINT_URL:-http://host.docker.internal:4566}"

if [[ -z "$ENDPOINT_URL" ]]; then
  echo "ERROR: ENDPOINT_URL is empty. Aborting."
  exit 1
fi

echo "Using endpoint: $ENDPOINT_URL"

echo "Deploying SQS..."
docker run --rm -v "$PWD":"$PWD" -w "$PWD" \
  -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  -e AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION" \
  amazon/aws-cli \
  cloudformation create-stack \
  --stack-name sqs-stack \
  --template-body file://infra/cloudformation/sqs.yml \
  --endpoint-url "$ENDPOINT_URL" \
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
  --endpoint-url "$ENDPOINT_URL" \
  --region us-east-1
