#!/bin/bash

# Define log function for consistent logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Setting up iptables-persistent..."
# # Check if iptables-persistent is already installed
# if dpkg -l | grep -q iptables-persistent; then
#     echo "iptables-persistent is already installed."
# else
#     echo "Installing iptables-persistent..."
# fi
# # Install iptables-persistent
sudo apt-get install iptables-persistent -y

read -p "Please enter your Application Port (default: 8080): " PORT
# Set default port if not provided
PORT=${PORT:-8080}


log "Add redirect port $PORT to 80"
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $PORT
sudo iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-port $PORT
sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null
sudo  iptables -t nat --line-numbers -n -L