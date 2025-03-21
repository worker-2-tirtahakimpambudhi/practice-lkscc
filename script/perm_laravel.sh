#!/bin/bash

read -p "Enter Folder name (default: lksdiycc2024): " input_folder_name

# Set default values if no input provided
FOLDER_NAME=${input_folder_name:-"lksdiycc2024"}

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


echo "1. **PERMISSION SETUP**"
# Change permissions with validation
sudo chmod -R 777 /var/www/$FOLDER_NAME/storage || handle_error "Setting storage permissions"
sudo chmod -R 775 /var/www/$FOLDER_NAME/public || handle_error "Setting public permissions"
sudo chmod -R 777 /var/www/$FOLDER_NAME/bootstrap || handle_error "Setting bootstrap ownership"
sudo chmod -R 777 /var/www/$FOLDER_NAME/bootstrap/cache || handle_error "Setting cache ownership"

sudo chown -R www-data:www-data /var/www/$FOLDER_NAME/storage || handle_error "Setting storage ownership"
sudo chown -R www-data:www-data /var/www/$FOLDER_NAME/bootstrap || handle_error "Setting bootstrap ownership"
sudo chown -R www-data:www-data /var/www/$FOLDER_NAME/bootstrap/cache || handle_error "Setting cache ownership"
validate_command "Permission setup"