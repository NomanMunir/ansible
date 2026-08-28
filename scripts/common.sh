#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo " [COMMON] Bootstrapping $(hostname)..."
echo "========================================="

export DEBIAN_FRONTEND=noninteractive

# Update system package list
echo "--> Updating package list..."
apt-get update -y

# Install essential dependencies and Python (required by Ansible)
echo "--> Installing common utilities..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    software-properties-common \
    python3 \
    python3-pip \
    python3-venv \
    sshpass \
    tree \
    net-tools \
    rsync

# Configure /etc/hosts for name resolution across all lab nodes
echo "--> Configuring /etc/hosts..."
sed -i '/control-node/d' /etc/hosts
sed -i '/target-1/d' /etc/hosts
sed -i '/target-2/d' /etc/hosts

cat << 'EOF' >> /etc/hosts
192.168.77.10 control-node
192.168.77.11 target-1
192.168.77.12 target-2
EOF

# Create dedicated 'ansible' user if it doesn't already exist
echo "--> Setting up 'ansible' user and permissions..."
if ! id -u ansible &>/dev/null; then
    useradd -m -s /bin/bash -c "Ansible Admin User" ansible
    echo "ansible:ansible" | chpasswd
fi

# Ensure both 'vagrant' and 'ansible' have passwordless sudo
echo "vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
chmod 0440 /etc/sudoers.d/vagrant /etc/sudoers.d/ansible

# Enable SSH password authentication (handy for initial connection and lab practice)
echo "--> Enabling SSH password authentication..."
sed -i 's/^[#]*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^[#]*KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config

# Create sshd drop-in override for Ubuntu 22.04+ if directory exists
if [ -d /etc/ssh/sshd_config.d ]; then
    echo "PasswordAuthentication yes" > /etc/ssh/sshd_config.d/60-ansible-lab.conf
fi

systemctl restart ssh || systemctl restart sshd

echo "========================================="
echo " [COMMON] $(hostname) setup complete!"
echo "========================================="
