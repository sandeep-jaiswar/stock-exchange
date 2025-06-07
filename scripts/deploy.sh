#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration Variables ---
# These should be set as environment variables before running the script.
# Example:
# export ENVIRONMENT_NAME="dev"
# export AWS_DEFAULT_REGION="eu-central-1"
# export DB_MASTER_USERNAME="mysecretusername"
# export DB_MASTER_PASSWORD="mysecretpassword"
# export GATEWAY_CONTAINER_IMAGE="your-ecr-repo/gateway:latest"
# export MARKETDATA_CONTAINER_IMAGE="your-ecr-repo/marketdata:latest"
# export BACKOFFICE_CLIENT_CONTAINER_IMAGE="your-ecr-repo/backoffice-client:latest"
# export VPC_CIDR="10.0.0.0/16" # Optional, use default in template if not set
# export DB_ALLOCATED_STORAGE="20" # Optional, use default
# export DB_INSTANCE_CLASS="db.t3.micro" # Optional, use default
# export ALB_LISTENER_PORT="80" # Optional, use default
# export ALB_INGRESS_CIDR="0.0.0.0/0" # WARNING: Restrict this in production!

# Check if essential environment variables are set
if [ -z "$ENVIRONMENT_NAME" ] || [ -z "$AWS_DEFAULT_REGION" ] || [ -z "$DB_MASTER_USERNAME" ] || [ -z "$DB_MASTER_PASSWORD" ] || [ -z "$GATEWAY_CONTAINER_IMAGE" ] || [ -z "$MARKETDATA_CONTAINER_IMAGE" ] || [ -z "$BACKOFFICE_CLIENT_CONTAINER_IMAGE" ]; then
  echo "Error: Essential environment variables not set."
  echo "Please set ENVIRONMENT_NAME, AWS_DEFAULT_REGION, DB_MASTER_USERNAME, DB_MASTER_PASSWORD,"
  echo "GATEWAY_CONTAINER_IMAGE, MARKETDATA_CONTAINER_IMAGE, and BACKOFFICE_CLIENT_CONTAINER_IMAGE."
  exit 1
fi

# --- AWS CLI Configuration (ensure you have AWS credentials configured) ---
# This script assumes you have AWS credentials configured in your environment
# (e.g., via environment variables, IAM role, or AWS config file).
# export AWS_ACCESS_KEY_ID="..."
# export AWS_SECRET_ACCESS_KEY="..."
# export AWS_SESSION_TOKEN="..." # If using temporary credentials

# Define the main CloudFormation stack name
STACK_NAME="${ENVIRONMENT_NAME}-StockExchange-Infra"
TEMPLATE_FILE="infra/cloudformation/main.yml"

echo "Deploying CloudFormation stack: ${STACK_NAME} to region ${AWS_DEFAULT_REGION}..."

# Use aws cloudformation deploy for simpler deployments (handles create/update)
# This command packages local artifacts (nested templates) and uploads them to S3.
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE_FILE" \
  --region "$AWS_DEFAULT_REGION" \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --parameter-overrides \
    EnvironmentName="$ENVIRONMENT_NAME" \
    DatabaseMasterUsername="$DB_MASTER_USERNAME" \
    DatabaseMasterUserPassword="$DB_MASTER_PASSWORD" \
    GatewayContainerImage="$GATEWAY_CONTAINER_IMAGE" \
    MarketDataContainerImage="$MARKETDATA_CONTAINER_IMAGE" \
    BackofficeClientContainerImage="$BACKOFFICE_CLIENT_CONTAINER_IMAGE" \
    $( [ -n "$VPC_CIDR" ] && echo "VpcCidr=$VPC_CIDR" ) \
    $( [ -n "$DB_ALLOCATED_STORAGE" ] && echo "DBAllocatedStorage=$DB_ALLOCATED_STORAGE" ) \
    $( [ -n "$DB_INSTANCE_CLASS" ] && echo "DBInstanceClass=$DB_INSTANCE_CLASS" ) \
    $( [ -n "$ALB_LISTENER_PORT" ] && echo "ALBListenerPort=$ALB_LISTENER_PORT" ) \
    $( [ -n "$ALB_INGRESS_CIDR" ] && echo "ALBSecurityGroupIngressCidr=$ALB_INGRESS_CIDR" ) 
    # Add other optional parameters similarly

echo "CloudFormation deployment initiated for stack ${STACK_NAME}."
echo "You can monitor the progress in the AWS Management Console."

# Note: This script removes the Docker dependency and endpoint-url for a standard AWS deployment.
# If you still need to deploy to LocalStack, consider having a separate script or
# adding conditional logic based on an environment variable (e.g., IS_LOCALSTACK).
