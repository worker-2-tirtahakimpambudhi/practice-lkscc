#!/bin/bash

# Update and install dependencies
sudo apt update -y
sudo apt install curl unzip

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh 
# Check docker version if not exist echo error
if ! command -v docker &> /dev/null; then
    echo "Error: Docker installation failed"
    exit 1
fi
echo "Docker successfully installed: $(docker --version)"

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip
sudo ./aws/install 
# Check awscli --version if not exist echo error
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI installation failed"
    exit 1
fi
echo "AWS CLI successfully installed: $(aws --version)"

# Interactive input for variables
read -p "Enter AWS region [default: us-east-1]: " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

read -p "Enter ECR username [default: AWS]: " INPUT_USERNAME
INPUT_USERNAME=${INPUT_USERNAME:-AWS}

read -p "Enter your AWS Account ID: " AWS_ACCOUNT_ID
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "AWS Account ID is required"
    exit 1
fi

read -p "Enter ECR repository name [default: wordpress]: " REPO_NAME
REPO_NAME=${REPO_NAME:-wordpress}

read -p "Enter image tag [default: latest]: " IMAGE_TAG
IMAGE_TAG=${IMAGE_TAG:-latest}

# Set the password and repository variables based on inputs
INPUT_REGISTRY_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"

# Display the values (for confirmation)
echo "============================================"
echo "Region: $AWS_REGION"
echo "Username: $INPUT_USERNAME"
echo "Repository: $INPUT_REGISTRY_REPOSITORY"
echo "============================================"
read -p "Proceed with these values? (y/n): " CONFIRM
if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "Aborted by user"
    exit 0
fi

# Log in to ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | sudo docker login --username $INPUT_USERNAME --password-stdin  $(echo $INPUT_REGISTRY_REPOSITORY | cut -d'/' -f1)

read -p "Enter Docker repository name [default: wordpress]: " DCKR_REPO
DCKR_REPO=${DCKR_REPO:-wordpress}

read -p "Enter image tag [default: latest]: " DCKR_IMAGE_TAG
DCKR_IMAGE_TAG=${DCKR_IMAGE_TAG:-latest}

# Pull WordPress image
echo "Pulling $DCKR_REPO:$DCKR_IMAGE_TAG Docker image..."
sudo docker pull $DCKR_REPO:$DCKR_IMAGE_TAG

# Tag the image for ECR
echo "Tagging $DCKR_REPO:$DCKR_IMAGE_TAG image for ECR..."
sudo docker tag $DCKR_REPO:$DCKR_IMAGE_TAG $INPUT_REGISTRY_REPOSITORY

# Push the image to ECR
echo "Pushing $DCKR_REPO:$DCKR_IMAGE_TAG image to ECR..."
sudo docker push $INPUT_REGISTRY_REPOSITORY

echo "$DCKR_REPO:$DCKR_IMAGE_TAG image successfully pushed to ECR"