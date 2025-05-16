#!/bin/bash

# This script sets up AWS users for LKS with necessary permissions and access keys.

# Define log function for consistent logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Setting up AWS users..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    log "AWS CLI is not installed. Please install it first."
    exit 1
fi

read -p "Please enter the username (default: tirtahakimpambudhi-lksdiycc2025): " AWS_USERS
AWS_USERS=${AWS_USERS:-tirtahakimpambudhi-lksdiycc2025}

log "AWS user: $AWS_USERS"

# Check if user already exists
if aws iam get-user --user-name "$AWS_USERS" &> /dev/null; then
    log "User $AWS_USERS already exists."
else
    log "Creating user $AWS_USERS..."
    aws iam create-user --user-name "$AWS_USERS"
fi

# Define policies to attach
POLICIES=(
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  "arn:aws:iam::aws:policy/IAMFullAccess"
  "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
  "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
  "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
  "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
)

log "Attaching standard AWS managed policies..."
for POLICY_ARN in "${POLICIES[@]}"; do
    log "Attaching $POLICY_ARN..."
    aws iam attach-user-policy --user-name "$AWS_USERS" --policy-arn "$POLICY_ARN"
done

# Create custom policy EksFullAccess if not exists
CUSTOM_POLICY_NAME="EksFullAccess"
CUSTOM_POLICY_DOC='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "eks:*",
            "Resource": "*"
        },
        {
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters"
            ],
            "Resource": [
                "arn:aws:ssm:*:277789128961:parameter/aws/*",
                "arn:aws:ssm::*:parameter/aws/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "kms:CreateGrant",
                "kms:DescribeKey"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "logs:PutRetentionPolicy"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}'

CUSTOM_POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='$CUSTOM_POLICY_NAME'].Arn" --output text)

if [[ -z "$CUSTOM_POLICY_ARN" ]]; then
    log "Creating custom policy $CUSTOM_POLICY_NAME..."
    CUSTOM_POLICY_ARN=$(aws iam create-policy --policy-name "$CUSTOM_POLICY_NAME" --policy-document "$CUSTOM_POLICY_DOC" --query "Policy.Arn" --output text)
else
    log "Custom policy $CUSTOM_POLICY_NAME already exists."
fi

log "Attaching custom policy $CUSTOM_POLICY_NAME..."
aws iam attach-user-policy --user-name "$AWS_USERS" --policy-arn "$CUSTOM_POLICY_ARN"

# Generate access key for AWS CLI usage
log "Creating access key for user $AWS_USERS..."
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name "$AWS_USERS" --output json)

AWS_ACCESS_KEY_ID=$(echo "$ACCESS_KEY_OUTPUT" | jq -r '.AccessKey.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo "$ACCESS_KEY_OUTPUT" | jq -r '.AccessKey.SecretAccessKey')

log "Access key created successfully."

echo "================ AWS CLI Credentials ================"
echo "aws_access_key_id:     $AWS_ACCESS_KEY_ID"
echo "aws_secret_access_key: $AWS_SECRET_ACCESS_KEY"
echo "====================================================="

log "You can now use these credentials with: aws configure"

log "Setup completed successfully."