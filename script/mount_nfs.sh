#!/bin/bash
# Define fs_entry and mount_point variables from arguments
fs_entry=""
mount_point=""

read -p  "Enter EFS Entrypoint : " fs_entry
read -p  "Enter Directory Mount : " mount_point

sudo apt install nfs-common -y



# Create mount point directory if it doesn't exist
if [ ! -d "$mount_point" ]; then
    mkdir -p "$mount_point"
fi

# Add entry to /etc/fstab for EFS mounting
fstab_entry="${fs_entry}:/ ${mount_point} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0"

# Check if the entry already exists in /etc/fstab
if ! grep -qs "${fs_entry}:/" /etc/fstab; then
    echo "$fstab_entry" | sudo tee -a /etc/fstab > /dev/null
    echo "Entry added to /etc/fstab."
else
    echo "Entry already exists in /etc/fstab."
fi

# Mount based on /etc/fstab
sudo mount -a

# Check mount status
if mountpoint -q "$mount_point"; then
    echo "Mount successful at $mount_point"
else
    echo "Mount failed. Check configuration and try again."
    exit 1
fi

