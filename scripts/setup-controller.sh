#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo " [CONTROLLER] Setting up Ansible Controller..."
echo "========================================="

export DEBIAN_FRONTEND=noninteractive

# Add official Ansible PPA for the latest stable Ansible release
echo "--> Adding Ansible PPA..."
add-apt-repository -y ppa:ansible/ansible
apt-get update -y
apt-get install -y ansible

# Function to configure SSH key and Ansible workspace for a user
setup_user_environment() {
    local USERNAME="$1"
    local USER_PASS="$2"
    local USER_HOME
    USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)

    echo "--> Configuring SSH keypair for $USERNAME..."
    mkdir -p "$USER_HOME/.ssh"
    if [ ! -f "$USER_HOME/.ssh/id_rsa" ]; then
        ssh-keygen -t rsa -b 2048 -f "$USER_HOME/.ssh/id_rsa" -N "" -q
    fi
    chown -R "$USERNAME:$USERNAME" "$USER_HOME/.ssh"
    chmod 700 "$USER_HOME/.ssh"
    chmod 600 "$USER_HOME/.ssh/id_rsa"
    chmod 644 "$USER_HOME/.ssh/id_rsa.pub"

    # Distribute SSH public key to target nodes
    TARGET_NODES=("target-1" "target-2" "control-node")
    for TARGET in "${TARGET_NODES[@]}"; do
        echo "--> Copying SSH key to $TARGET for user $USERNAME..."
        # Wait until target is reachable on port 22
        for attempt in {1..20}; do
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

    # Create Ansible Lab Workspace
    local LAB_DIR="$USER_HOME/ansible-lab"
    mkdir -p "$LAB_DIR/playbooks"

    # Create ansible.cfg
    cat << EOF > "$LAB_DIR/ansible.cfg"
[defaults]
inventory = ./inventory.ini
remote_user = $USERNAME
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
deprecation_warnings = False

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF

    # Create inventory.ini
    cat << 'EOF' > "$LAB_DIR/inventory.ini"
[control]
control-node ansible_host=192.168.56.10

[webservers]
target-1 ansible_host=192.168.56.11

[dbservers]
target-2 ansible_host=192.168.56.12

[targets:children]
webservers
dbservers

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

    # Create Ping Test Playbook
    cat << 'EOF' > "$LAB_DIR/playbooks/01-ping.yml"
---
- name: Test Connectivity to All Nodes
  hosts: all
  gather_facts: false
  tasks:
    - name: Ping host
      ansible.builtin.ping:
EOF

    # Create Facts Gathering Playbook
    cat << 'EOF' > "$LAB_DIR/playbooks/02-gather-facts.yml"
---
- name: Gather Facts and Show System Info
  hosts: targets
  tasks:
    - name: Display Hostname and IP
      ansible.builtin.debug:
        msg: "Hostname: {{ ansible_hostname }} | OS: {{ ansible_distribution }} {{ ansible_distribution_version }} | IP: {{ ansible_default_ipv4.address }}"
EOF

    # Create Sample Nginx Setup Playbook
    cat << 'EOF' > "$LAB_DIR/playbooks/03-install-nginx.yml"
---
- name: Install and Configure Nginx on Webservers
  hosts: webservers
  become: true
  tasks:
    - name: Update apt cache and install Nginx
      ansible.builtin.apt:
        name: nginx
        state: present
        update_cache: true

    - name: Ensure Nginx service is running and enabled
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true

    - name: Deploy custom index page
      ansible.builtin.copy:
        content: "<h1>Hello from Ansible Managed Node: {{ ansible_hostname }}</h1>\n"
        dest: /var/www/html/index.html
        mode: '0644'
EOF

    chown -R "$USERNAME:$USERNAME" "$LAB_DIR"
}

# Setup for both 'vagrant' and 'ansible' users
setup_user_environment "vagrant" "vagrant"
setup_user_environment "ansible" "ansible"

echo "========================================="
echo " [CONTROLLER] Ansible Controller Ready!"
echo "========================================="
