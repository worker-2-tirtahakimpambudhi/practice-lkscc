#!/bin/bash

read -p "Enter Golang Version (default: 1.24.1)" input_go_version

GO_VERSION=${input_go_version:-"1.24.1"}

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


echo "1. *** Download Source Code Go ***"
wget https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz -O go.tar.gz || handle_error "Download Source Code Go"

validate_command "Go Download"

echo "2. *** Installing Go with Extract the Source Code ***"
sudo tar -xzvf go.tar.gz -C /usr/local || handle_error "Extract Go"

validate_command "Installing Go with Extract the Source Code"

echo "3. *** Add Environment Variable to Go ***"
echo export PATH=$HOME/go/bin:/usr/local/go/bin:$PATH >> ~/.profile
source ~/.profile

go_version=$(go version)
echo "Go Version $go_version"