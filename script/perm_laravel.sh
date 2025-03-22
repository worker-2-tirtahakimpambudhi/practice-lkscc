#!/bin/bash

read -p "Enter Folder name (default: lksdiycc2024): " input_folder_name

# Set default values if no input provided
FOLDER_NAME=${input_folder_name:-"lksdiycc2024"}
LARAVEL_PATH="/var/www/$FOLDER_NAME"

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
echo "Setting appropriate ownership and permissions..."

# Set user as the owner and webserver as the group
sudo chown -R www-data:www-data $LARAVEL_PATH || handle_error "Setting ownership"
validate_command "Setting ownership to www-data:www-data"

# Set secure file permissions (644)
sudo find $LARAVEL_PATH -type f -exec chmod 664 {} \; || handle_error "Setting file permissions"
validate_command "Setting file permissions to 664"

# Set secure directory permissions (755)
sudo find $LARAVEL_PATH -type d -exec chmod 775 {} \; || handle_error "Setting directory permissions"
validate_command "Setting directory permissions to 775"

# Give webserver specific permissions to directories that need write access
sudo chgrp -R www-data $LARAVEL_PATH/storage $LARAVEL_PATH/bootstrap/cache || handle_error "Setting special directories group"
sudo chmod -R ug+rwx $LARAVEL_PATH/storage $LARAVEL_PATH/bootstrap/cache || handle_error "Setting special directories permissions"
validate_command "Setting special permissions for storage and cache directories"

echo "Permission setup completed successfully with secure settings."
echo "Your Laravel application should now have the correct permissions while maintaining security."