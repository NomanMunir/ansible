#!/usr/bin/env bash
# ==============================================================================
# Ansible Lab - Host Environment Setup Script
# Installs ONLY what the host machine needs to spin up the VMs:
# - Vagrant
# - Hypervisor / Virtualization tools (KVM / Libvirt)
# - Vagrant Libvirt plugin
#
# (Ansible and all course tools are isolated inside the 'control-node' VM)
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}      Ansible Lab - Host Machine Setup               ${NC}"
echo -e "${BLUE}=====================================================${NC}"

if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

echo -e "\n${YELLOW}[1/4] Updating package repositories...${NC}"
$SUDO apt-get update -y

echo -e "\n${YELLOW}[2/4] Installing Vagrant...${NC}"
if ! command -v vagrant &>/dev/null; then
    $SUDO apt-get install -y apt-transport-https ca-certificates curl wget gnupg lsb-release
    wget -O- https://apt.releases.hashicorp.com/gpg | $SUDO gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg --yes
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | $SUDO tee /etc/apt/sources.list.d/hashicorp.list
    $SUDO apt-get update -y
    $SUDO apt-get install -y vagrant
    echo -e "${GREEN}✓ Vagrant installed: $(vagrant --version)${NC}"
else
    echo -e "${GREEN}✓ Vagrant is already installed: $(vagrant --version)${NC}"
fi

echo -e "\n${YELLOW}[3/4] Setting up Virtualization Tools (KVM / Libvirt)...${NC}"
$SUDO apt-get install -y \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    libvirt-dev \
    ruby-dev \
    libxslt1-dev \
    libxml2-dev \
    zlib1g-dev \
    build-essential \
    pkg-config

# Add current user to virtualization groups
$SUDO usermod -aG kvm,libvirt "$USER" 2>/dev/null || true

# Start and enable libvirtd service
if command -v systemctl &>/dev/null; then
    $SUDO systemctl enable --now libvirtd || true
    $SUDO virsh net-start default 2>/dev/null || true
    $SUDO virsh net-autostart default 2>/dev/null || true
fi

echo -e "\n${YELLOW}[4/4] Checking Vagrant Libvirt Plugin...${NC}"
if ! vagrant plugin list | grep -q "vagrant-libvirt"; then
    echo "Installing vagrant-libvirt plugin..."
    vagrant plugin install vagrant-libvirt
    echo -e "${GREEN}✓ vagrant-libvirt plugin installed.${NC}"
else
    echo -e "${GREEN}✓ vagrant-libvirt plugin is already present.${NC}"
fi

echo -e "\n${BLUE}=====================================================${NC}"
echo -e "${GREEN}✓ Host setup complete! Ready to launch VMs.${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo -e "\nTo start the 3-node lab:"
echo -e "  ${YELLOW}vagrant up --provider=libvirt${NC}"
echo -e "  (or: ${YELLOW}vagrant up --provider=virtualbox${NC})\n"
echo -e "Ansible and all playbooks will be automatically installed inside ${GREEN}control-node${NC}!"
