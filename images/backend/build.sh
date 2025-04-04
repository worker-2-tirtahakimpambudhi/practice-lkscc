#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Prompt user for application name with a default value
read -p "Enter application name (default: main): " input_app_name
APP_NAME=${input_app_name:-main}

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Go is not installed. Please install Go and try again."
    exit 1
fi

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf ./bin
mkdir -p ./bin

# Install dependencies
echo "Installing dependencies..."
go mod tidy

# Build the application
echo "Building the application..."
go build -o ./bin/$APP_NAME

# Success message
echo "Build completed successfully. The binary is located at ./bin/$APP_NAME"