#!/bin/bash

# Define log function for consistent logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Define function to handle errors 
handle_error() {
    log "ERROR: $1"
    exit 1
}

# Define function to validate command execution
validate_command() {
    if [ $? -ne 0 ]; then
        handle_error "$1 failed"
    else
        log "✓ $1 completed successfully"
    fi
}

# Start script execution
log "Script execution started"

log "1. Installing Required Dependencies"
npm i
validate_command "Installing dependencies"

log "2. Setting up AWS configuration"

# Collect AWS configuration with defaults
log "Please provide your AWS configuration details:"
read -p "AWS Region (default: us-east-1): " REGION
REGION=${REGION:-us-east-1}

read -p "AWS Access Key ID: " ACCESS_KEY
if [ -z "$ACCESS_KEY" ]; then
    handle_error "AWS Access Key ID cannot be empty"
fi

read -p "AWS Secret Access Key: " SECRET_KEY
if [ -z "$SECRET_KEY" ]; then
    handle_error "AWS Secret Access Key cannot be empty"
fi

read -p "AWS Session Token (optional): " SESSION_TOKEN

read -p "AWS S3 Bucket Name: " BUCKET_NAME
if [ -z "$BUCKET_NAME" ]; then
    handle_error "AWS S3 Bucket Name cannot be empty"
fi

log "3. Setting up application configuration"
read -p "Application Port (default: 8080): " PORT
PORT=${PORT:-8080}

read -p "Application Host (default: 0.0.0.0): " HOST
HOST=${HOST:-0.0.0.0}

read -p "Service name: " SERVICE_NAME
if [ -z "$SERVICE_NAME" ]; then
    SERVICE_NAME="nodeapp"
    log "Using default service name: nodeapp"
fi

read -p "Application path (default: /home/ubuntu/index.js): " APP_PATH
APP_PATH=${APP_PATH:-/home/ubuntu/index.js}

read -p "Working directory (default: /home/ubuntu): " WORK_DIR
WORK_DIR=${WORK_DIR:-/home/ubuntu}

read -p "User (default: ubuntu): " USER
USER=${USER:-ubuntu}

read -p "Group (default: ubuntu): " GROUP
GROUP=${GROUP:-ubuntu}

# Export AWS credentials to environment
log "4. Exporting AWS credentials to environment"
cat << EOF >> ~/.bashrc
# AWS Configuration
export AWS_REGION="${REGION}"
export AWS_ACCESS_KEY_ID="${ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${SECRET_KEY}"
EOF

# Only add SESSION_TOKEN to bashrc if it's not empty
if [ ! -z "$SESSION_TOKEN" ]; then
    echo "export AWS_SESSION_TOKEN=\"${SESSION_TOKEN}\"" >> ~/.bashrc
    log "Session token added to environment variables"
else
    log "Session token is empty, skipping environment variable setup"
fi

# Add the rest of the environment variables
cat << EOF >> ~/.bashrc
export AWS_BUCKET_NAME="${BUCKET_NAME}"
export PORT="${PORT}"
export HOST="${HOST}"
EOF

source ~/.bashrc
validate_command "Exporting and sourcing AWS credentials"

# Find the node binary path dynamically
NODE_PATH=$(which node)
validate_command "Finding Node.js binary path"
log "Using Node.js from: ${NODE_PATH}"

# Create systemd service file
log "5. Creating systemd service file"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# Start building service file content
SERVICE_CONTENT="[Unit]
Description=${SERVICE_NAME} Node.js Application
After=network.target

[Service]
ExecStart=${NODE_PATH} ${APP_PATH}
Restart=always
User=${USER}
Group=${GROUP}
WorkingDirectory=${WORK_DIR}
Environment=NODE_ENV=production
Environment=PORT=${PORT}
Environment=HOST=${HOST}
Environment=AWS_REGION=${REGION}
Environment=AWS_ACCESS_KEY_ID=${ACCESS_KEY}
Environment=AWS_SECRET_ACCESS_KEY=${SECRET_KEY}
"

# Add SESSION_TOKEN environment only if it's not empty
if [ ! -z "$SESSION_TOKEN" ]; then
    SERVICE_CONTENT="${SERVICE_CONTENT}Environment=AWS_SESSION_TOKEN=${SESSION_TOKEN}
"
fi

# Complete the service file content
SERVICE_CONTENT="${SERVICE_CONTENT}Environment=AWS_BUCKET_NAME=${BUCKET_NAME}
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${SERVICE_NAME}

[Install]
WantedBy=multi-user.target"

# Write service file
echo "$SERVICE_CONTENT" | sudo tee $SERVICE_FILE > /dev/null
validate_command "Creating service file"

# Set proper permissions for service file
sudo chmod 644 $SERVICE_FILE
validate_command "Setting service file permissions"

# Enable and start service
log "6. Enabling and starting the service"
sudo systemctl daemon-reload
validate_command "Systemd daemon reload"

sudo systemctl enable ${SERVICE_NAME}.service
validate_command "Enabling ${SERVICE_NAME} service"

sudo systemctl start ${SERVICE_NAME}.service
validate_command "Starting ${SERVICE_NAME} service"

log "Add redirect port $PORT to 80"
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $PORT
sudo  iptables -t nat --line-numbers -n -L

# Check service status
log "7. Checking service status"
sudo systemctl status ${SERVICE_NAME}.service
validate_command "Service status check"

log "8. Service deployment completed successfully"
log "To check logs use: sudo journalctl -u ${SERVICE_NAME}.service"

exit 0