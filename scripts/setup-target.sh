#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo " [TARGET] Configuring $(hostname)..."
echo "========================================="

# Ensure SSH directory for both vagrant and ansible users exists with proper permissions
for USERNAME in vagrant ansible; do
    USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)
    mkdir -p "$USER_HOME/.ssh"
    chmod 700 "$USER_HOME/.ssh"
    touch "$USER_HOME/.ssh/authorized_keys"
    chmod 600 "$USER_HOME/.ssh/authorized_keys"
    chown -R "$USERNAME:$USERNAME" "$USER_HOME/.ssh"
done

echo "========================================="
echo " [TARGET] $(hostname) is ready for Ansible!"
echo "========================================="
