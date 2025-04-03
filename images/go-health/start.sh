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

log "1. Checking and installing Go"
# Check if Go is installed
if ! command -v go &> /dev/null; then
    log "Go is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y golang
    validate_command "Installing Go"
else
    log "Go is already installed: $(go version)"
fi

log "2. Setting up MySQL configuration"
# Collect MySQL configuration
read -p "MySQL Username: " MYSQL_USER
if [ -z "$MYSQL_USER" ]; then
    handle_error "MySQL Username cannot be empty"
fi

read -p "MySQL Password: " MYSQL_PASSWORD
if [ -z "$MYSQL_PASSWORD" ]; then
    handle_error "MySQL Password cannot be empty"
fi

read -p "MySQL Host: " MYSQL_HOST
if [ -z "$MYSQL_HOST" ]; then
    handle_error "MySQL Host cannot be empty"
fi

read -p "MySQL Port (default: 3306): " MYSQL_PORT
MYSQL_PORT=${MYSQL_PORT:-3306}

read -p "MySQL Database: " MYSQL_DATABASE
if [ -z "$MYSQL_DATABASE" ]; then
    handle_error "MySQL Database cannot be empty"
fi

log "3. Setting up Redis configuration"
read -p "Redis Cluster (true/false, default: false): " REDIS_CLUSTER
REDIS_CLUSTER=${REDIS_CLUSTER:-false}

read -p "Redis Hosts (e.g., host:port): " REDIS_HOSTS
if [ -z "$REDIS_HOSTS" ]; then
    handle_error "Redis Hosts cannot be empty"
fi

read -p "Redis Username (optional): " REDIS_USERNAME

read -p "Redis Password (optional): " REDIS_PASSWORD

read -p "Redis TLS (true/false, default: true): " REDIS_TLS
REDIS_TLS=${REDIS_TLS:-true}

read -p "Redis TLS Insecure (true/false, default: true): " REDIS_TLS_INSECURE
REDIS_TLS_INSECURE=${REDIS_TLS_INSECURE:-true}

log "4. Setting up application configuration"
read -p "Application Port (default: 80): " PORT
PORT=${PORT:-80}

read -p "Application Host (default: 0.0.0.0): " HOST
HOST=${HOST:-0.0.0.0}

read -p "Go source directory (default: ./): " GO_SRC_DIR
GO_SRC_DIR=${GO_SRC_DIR:-./}

read -p "Binary output path (default: ./app): " BINARY_PATH
BINARY_PATH=${BINARY_PATH:-./app}

read -p "Service name: " SERVICE_NAME
if [ -z "$SERVICE_NAME" ]; then
    SERVICE_NAME="goapp"
    log "Using default service name: goapp"
fi

read -p "User for service (default: ubuntu): " USER
USER=${USER:-ubuntu}

read -p "Group for service (default: ubuntu): " GROUP
GROUP=${GROUP:-ubuntu}

read -p "Working directory for service (default: /home/ubuntu): " WORK_DIR
WORK_DIR=${WORK_DIR:-/home/ubuntu}

# Go to source directory
cd "$GO_SRC_DIR"
log "Moved to source directory: $(pwd)"

# Install Go dependencies
log "5. Installing Go dependencies"
go mod tidy
validate_command "Running go mod tidy"

go get -v ./...
validate_command "Installing Go dependencies"

# Build Go application
log "6. Building Go application"
go build -v -o "$BINARY_PATH"
validate_command "Building Go application"

# Get absolute path of binary
BINARY_PATH=$(realpath "$BINARY_PATH")
log "Binary built at: $BINARY_PATH"

# Export environment variables to .env file
log "7. Creating .env file"
ENV_FILE="$WORK_DIR/.env"

cat << EOF > $ENV_FILE
# MySQL Configuration
MYSQL_USER=${MYSQL_USER}
MYSQL_PASSWORD=${MYSQL_PASSWORD}
MYSQL_HOST=${MYSQL_HOST}
MYSQL_PORT=${MYSQL_PORT}
MYSQL_DATABASE=${MYSQL_DATABASE}

# Redis Configuration
REDIS_CLUSTER=${REDIS_CLUSTER}
REDIS_HOSTS=${REDIS_HOSTS}
EOF

# Only add Redis username if provided
if [ ! -z "$REDIS_USERNAME" ]; then
    echo "REDIS_USERNAME=${REDIS_USERNAME}" >> $ENV_FILE
    log "Redis username added to environment variables"
fi

# Only add Redis password if provided
if [ ! -z "$REDIS_PASSWORD" ]; then
    echo "REDIS_PASSWORD=${REDIS_PASSWORD}" >> $ENV_FILE
    log "Redis password added to environment variables"
fi

cat << EOF >> $ENV_FILE
REDIS_TLS=${REDIS_TLS}
REDIS_TLS_INSECURE=${REDIS_TLS_INSECURE}

# Application Configuration
PORT=${PORT}
HOST=${HOST}
EOF

validate_command "Creating .env file"

# Create systemd service file
log "8. Creating systemd service file"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# Create environment variables string for systemd service
ENV_VARS="Environment=MYSQL_USER=${MYSQL_USER}
Environment=MYSQL_PASSWORD=${MYSQL_PASSWORD}
Environment=MYSQL_HOST=${MYSQL_HOST}
Environment=MYSQL_PORT=${MYSQL_PORT}
Environment=MYSQL_DATABASE=${MYSQL_DATABASE}
Environment=REDIS_CLUSTER=${REDIS_CLUSTER}
Environment=REDIS_HOSTS=${REDIS_HOSTS}"

# Only add Redis username if provided
if [ ! -z "$REDIS_USERNAME" ]; then
    ENV_VARS="${ENV_VARS}
Environment=REDIS_USERNAME=${REDIS_USERNAME}"
fi

# Only add Redis password if provided
if [ ! -z "$REDIS_PASSWORD" ]; then
    ENV_VARS="${ENV_VARS}
Environment=REDIS_PASSWORD=${REDIS_PASSWORD}"
fi

ENV_VARS="${ENV_VARS}
Environment=REDIS_TLS=${REDIS_TLS}
Environment=REDIS_TLS_INSECURE=${REDIS_TLS_INSECURE}
Environment=PORT=${PORT}
Environment=HOST=${HOST}"

# Write service file using heredoc
sudo cat > $SERVICE_FILE <<- EOM
[Unit]
Description=${SERVICE_NAME} Go Application
After=network.target

[Service]
ExecStart=${BINARY_PATH}
Restart=always
User=${USER}
Group=${GROUP}
WorkingDirectory=${WORK_DIR}
${ENV_VARS}
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${SERVICE_NAME}

[Install]
WantedBy=multi-user.target
EOM

validate_command "Creating service file"

# Set proper permissions for service file
sudo chmod 644 $SERVICE_FILE
validate_command "Setting service file permissions"

# Enable and start service
log "9. Enabling and starting the service"
sudo systemctl daemon-reload
validate_command "Systemd daemon reload"

sudo systemctl enable ${SERVICE_NAME}.service
validate_command "Enabling ${SERVICE_NAME} service"

sudo systemctl start ${SERVICE_NAME}.service
validate_command "Starting ${SERVICE_NAME} service"

# Check service status
log "10. Checking service status"
sudo systemctl status ${SERVICE_NAME}.service
validate_command "Service status check"

log "11. Service deployment completed successfully"
log "To check logs use: sudo journalctl -u ${SERVICE_NAME}.service"

exit 0