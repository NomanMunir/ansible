#!/usr/bin/env bash
set -u

echo "=========================================================="
echo " [CONTROLLER] Configuring SSH Keys on control-node..."
echo "=========================================================="

export DEBIAN_FRONTEND=noninteractive

# Install sshpass (needed only for initial non-interactive key distribution)
apt-get update -y
apt-get install -y sshpass netcat-openbsd curl || true

# Function to configure and distribute SSH keys for a user
setup_ssh_keys() {
    local USERNAME="$1"
    local USER_PASS="$2"
    local USER_HOME
    USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)

    echo "--> Generating SSH keypair for $USERNAME (if not present)..."
    mkdir -p "$USER_HOME/.ssh"
    if [ ! -f "$USER_HOME/.ssh/id_rsa" ]; then
        ssh-keygen -t rsa -b 2048 -f "$USER_HOME/.ssh/id_rsa" -N "" -q
    fi
    chown -R "$USERNAME:$USERNAME" "$USER_HOME/.ssh"
    chmod 700 "$USER_HOME/.ssh"
    chmod 600 "$USER_HOME/.ssh/id_rsa"
    chmod 644 "$USER_HOME/.ssh/id_rsa.pub"

    # Distribute SSH public key to all nodes
    TARGET_NODES=("target-1" "target-2" "control-node")
    for TARGET in "${TARGET_NODES[@]}"; do
        echo "--> Copying SSH public key to $TARGET for $USERNAME..."
        for attempt in {1..15}; do
            if nc -z -w 2 "$TARGET" 22 2>/dev/null; then
                break
            fi
            sleep 2
        done

        sshpass -p "$USER_PASS" ssh-copy-id \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -i "$USER_HOME/.ssh/id_rsa.pub" \
            "$USERNAME@$TARGET" 2>/dev/null || true
    done
}

# Setup SSH keypair and distribute to targets for both 'vagrant' and 'ansible'
setup_ssh_keys "vagrant" "vagrant"
setup_ssh_keys "ansible" "ansible"

echo "=========================================================="
echo " [CONTROLLER] SSH Keys successfully configured!"
echo " Nodes: control-node (192.168.56.10)"
echo "        target-1     (192.168.56.11)"
echo "        target-2     (192.168.56.12)"
echo " You are now ready to install Ansible & learn step-by-step!"
echo "=========================================================="
