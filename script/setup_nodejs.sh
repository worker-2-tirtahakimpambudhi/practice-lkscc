#!/bin/bash

sudo apt update -y

sudo apt install curl -y

read -p "Enter NodeJS Version (default: 22) " input_nodejs_version

NODEJS_VERSION=${input_nodejs_version:-"22"}

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


echo "1. *** INSTALLING NODEJS ***"
# Download and install nvm with validation
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash || handle_error "NVM installation"
validate_command "NVM download"

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || handle_error "NVM source loading"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" || echo "NVM bash completion not loaded (non-critical)"

# Install Node.js
nvm install $NODEJS_VERSION || handle_error "Node.js installation"
validate_command "Node.js installation"
source ~/.profile
# Verify Node.js and npm
node_version=$(node -v)
npm_version=$(npm -v)
source ~/.profile
echo "Node.js version: $node_version"
echo "NPM version: $npm_version"