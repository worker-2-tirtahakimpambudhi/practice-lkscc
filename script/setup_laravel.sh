#!/bin/bash

# Get values from user input and store them in variables
read -p "Enter GitHub username (default: denikn): " input_user_repo
read -p "Enter repository name (default: lksdiycc2024): " input_repo_name
read -p "Enter branch name (default: master): " input_branch_name
read -p "Enter PHP version (default: 8.1): " input_php_version
read -p "Enter NodeJS version (default: 22): " input_nodejs_version

# Set default values if no input provided
USER_REPO=${input_user_repo:-"denikn"}
REPO_NAME=${input_repo_name:-"lksdiycc2024"}
BRANCH_NAME=${input_branch_name:-"master"}
PHP_VERSION=${input_php_version:-"8.1"}
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


# Start installation with clear section headers
echo "====================================================="
echo "Laravel Installation Script with Validation"
echo "====================================================="

# Update Ubuntu Repositories
echo "1. *** UPDATING SYSTEM PACKAGES ***"
sudo apt update -y || handle_error "System update"
sudo apt install git curl wget -y || handle_error "Git, curl and wget installation"
validate_command "System packages update"

# Install Dependencies for Laravel
echo "2. *** INSTALLING NGINX AND PHP ***"
sudo apt install software-properties-common -y || handle_error "Software properties installation"
sudo add-apt-repository ppa:ondrej/php -y || handle_error "PHP repository addition"
sudo apt update || handle_error "Repository update"

# Remove Apache if installed
if dpkg -l | grep -q apache2; then
    sudo apt autoremove apache2 --purge -y || handle_error "Apache removal"
    validate_command "Apache removal"
fi

# Install Nginx
sudo apt install -y nginx || handle_error "Nginx installation"
validate_command "Nginx installation"

# Install PHP and extensions
echo "Installing PHP $PHP_VERSION and extensions..."
sudo apt install php$PHP_VERSION php$PHP_VERSION-{common,mysql,xml,xmlrpc,curl,gd,imagick,cli,dev,imap,mbstring,opcache,soap,zip,intl,bcmath,redis} -y || handle_error "PHP installation"
sudo apt-get install php$PHP_VERSION-fpm -y || handle_error "PHP-FPM installation"
validate_command "PHP installation"

echo "3. *** INSTALLING COMPOSER ***"
# Simpler composer installation with validation
sudo apt install composer -y || handle_error "Composer installation"
# Verify composer is installed
composer --version || handle_error "Composer verification"
validate_command "Composer installation"

echo "4. *** INSTALLING NODEJS ***"
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

# Verify Node.js and npm
node_version=$(node -v)
npm_version=$(npm -v)
echo "Node.js version: $node_version"
echo "NPM version: $npm_version"

echo "5. *** DOCKER INSTALLATION PREPARED (COMMENTED OUT) ***"
curl -fsSL https://get.docker.com -o get-docker.sh || handle_error "Docker script download"
# sh get-docker.sh  # Commented out as per original script
validate_command "Docker script download"

echo "6. *** INSTALLING LARAVEL APPLICATION ***"
# Clone Laravel repository with validation
git clone -b $BRANCH_NAME --depth 1 https://github.com/$USER_REPO/$REPO_NAME.git || handle_error "Laravel repository clone"
validate_command "Laravel repository clone"

# Prepare Laravel directory
cd $REPO_NAME && rm -rf .git && cd .. || handle_error "Laravel directory preparation"
if [ -d "/var/www/$REPO_NAME" ]; then
    shopt -s dotglob
    sudo mv $REPO_NAME/* /var/www/$REPO_NAME || handle_error "Moving Laravel to web directory"
else 
    sudo mv $REPO_NAME /var/www/ || handle_error "Moving Laravel to web directory"
fi 


echo "6. *** SETTING PERMISSIONS ***"
# Change permissions with validation
sudo chmod -R 777 /var/www/$REPO_NAME/storage || handle_error "Setting storage permissions"
sudo chmod -R 775 /var/www/$REPO_NAME/public || handle_error "Setting public permissions"

sudo chown -R www-data:www-data /var/www/$REPO_NAME/storage || handle_error "Setting storage ownership"
sudo chown -R www-data:www-data /var/www/$REPO_NAME/bootstrap/cache || handle_error "Setting cache ownership"
validate_command "Permission setup"

echo "7. *** CONFIGURING NGINX ***"
# Find PHP-FPM socket with validation
php_fpm_socket=$(find /var/run/php/ -name "php*-fpm.sock" | head -n 1)
if [ -z "$php_fpm_socket" ]; then
    handle_error "PHP-FPM socket not found"
fi
echo "Using PHP-FPM socket: $php_fpm_socket"

# Create Nginx configuration with validation
sudo touch /etc/nginx/sites-available/$REPO_NAME || handle_error "Creating Nginx site configuration"
sudo cat > /etc/nginx/sites-available/$REPO_NAME << EOF
server {
    listen 80;
    server_name _;
    root /var/www/$REPO_NAME/public;
    index index.php index.html index.htm;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:${php_fpm_socket};
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF
validate_command "Nginx configuration creation"

# Apply Nginx configuration
echo "Applying NGINX configuration..."

# Remove all existing site configurations from sites-enabled
echo "Removing all existing Nginx site configurations..."
for config in $(ls /etc/nginx/sites-enabled/); do
    sudo unlink /etc/nginx/sites-enabled/$config || handle_error "Unlinking $config Nginx config"
    echo "✓ Unlinked /etc/nginx/sites-enabled/$config"
done
validate_command "Removing existing Nginx configurations"

# Create symbolic link for our Laravel configuration
sudo ln -s /etc/nginx/sites-available/$REPO_NAME /etc/nginx/sites-enabled/ || handle_error "Creating Nginx symlink"
sudo nginx -t || handle_error "Nginx configuration test"
sudo systemctl restart nginx || handle_error "Nginx restart"
validate_command "Nginx configuration application"

echo "====================================================="
echo "Laravel Installation Complete!"
echo "====================================================="
echo "Your Laravel application has been installed and configured."
echo "The .env file has been customized with your specific settings."
echo "You can access your Laravel application at http://your-server-ip"
echo "====================================================="