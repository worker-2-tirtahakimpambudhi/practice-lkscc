#!/bin/bash

read -p "Enter AWS Region (default: us-east-1)" input_aws_region

AWS_REGION=${input_aws_region:-"us-east-1"}

# Define function to handle errors
handle_error() {
    echo "ERROR: $1"
    exit 1
}

# Define function to validate command execution
validate_command() {
    if [ $? -ne 0 ]; then
        handle_error "$1 failed"
    else
        echo "✓ $1 completed successfully"
    fi
}

echo "1. **Setup Python and Cloudwatch Agent**"
sudo apt update -y && sudo apt install python -y | handle_error "Update Repository and Install Python"
curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py | handle_error "Install AWS Logs"
sudo python ./awslogs-agent-setup.py --region $AWS_REGION | handle_error "Generate Config for Syslog"
validate_command "Setup Cloudwatch"

echo "2. **Setup AWS Logs Configuration to Laravel Logs**"
sudo python ./awslogs-agent-setup.py --region $AWS_REGION --only-generate-config | handle_error "Generate Config for Laravel Log"
sudo service awslogs restart | handle_error "Restart AWSLogs"
