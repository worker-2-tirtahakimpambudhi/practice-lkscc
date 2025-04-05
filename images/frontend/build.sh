#!/bin/bash

# Script to automate the installation of dependencies for a Node.js project

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting dependency installation..."

# Check if Node.js and npm are installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js first."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "npm is not installed. Please install npm first."
    exit 1
fi

# Navigate to the script's directory
SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR"

# Check if package.json exists
if [ ! -f package.json ]; then
    echo "package.json not found. Please ensure you are in the correct directory."
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
npm install

echo "Dependencies installed successfully."