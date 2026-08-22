# 🚀 Ansible 3-Node Lab Environment (KodeKloud Course Ready)

This repository sets up a complete, automated 3-node Linux environment for Ansible training using **Vagrant**.

---

## 📐 Lab Architecture & Topology

```text
               +---------------------------+
               |       control-node        |
               |       192.168.56.10       |
               | (Ansible, SSH Key Master) |
               +-------------+-------------+
                             |
              +--------------+--------------+
              |                             |
              v                             v
+---------------------------+ +---------------------------+
|         target-1          | |         target-2          |
|       192.168.56.11       | |       192.168.56.12       |
|    (Group: webservers)    | |    (Group: dbservers)     |
+---------------------------+ +---------------------------+
```

| Node Name | Role | IP Address | User / Password | Specs |
| :--- | :--- | :--- | :--- | :--- |
| `control-node` | Ansible Controller | `192.168.56.10` | `vagrant` / `vagrant`<br>`ansible` / `ansible` | 2 vCPU, 2GB RAM |
| `target-1` | Managed Target 1 | `192.168.56.11` | `vagrant` / `vagrant`<br>`ansible` / `ansible` | 1 vCPU, 1GB RAM |
| `target-2` | Managed Target 2 | `192.168.56.12` | `vagrant` / `vagrant`<br>`ansible` / `ansible` | 1 vCPU, 1GB RAM |

---

## ⚡ Option A: Running Native in WSL2 (KVM / Libvirt)

If you want to run everything 100% inside WSL2 without VirtualBox:

### 1. Enable Nested Virtualization in Windows
In `C:\Users\<YourUsername>\.wslconfig`:
```ini
[wsl2]
nestedVirtualization=true
```
Then restart WSL in PowerShell: `wsl --shutdown`

### 2. Install KVM, Libvirt & Vagrant in WSL2
Inside your Ubuntu WSL2 terminal:
```bash
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils vagrant libvirt-dev build-essential
sudo usermod -aG kvm,libvirt $USER
newgrp libvirt

# Start libvirt service and default network
sudo systemctl enable --now libvirtd
sudo virsh net-start default 2>/dev/null || true
sudo virsh net-autostart default

# Install Vagrant Libvirt plugin
vagrant plugin install vagrant-libvirt
```

### 3. Launch Lab in WSL2
```bash
cd /path/to/ansible-lab-dir
vagrant up --provider=libvirt
```

---

## 💻 Option B: Running on Windows Host (VirtualBox)

If you prefer standard VirtualBox on Windows:

1. Install [VirtualBox](https://www.virtualbox.org/) and [Vagrant for Windows](https://developer.hashicorp.com/vagrant/install).
2. Open **PowerShell** or **Windows Terminal** in this project directory:
   ```powershell
   vagrant up
   ```

---

## 🎮 Accessing the Lab & Running Ansible

### 1. Connect to the Controller Node
From your terminal:
```bash
vagrant ssh control-node
```
*(Or directly via SSH: `ssh vagrant@192.168.56.10` with password `vagrant`)*

### 2. Navigate to the Ansible Lab Workspace
The setup script pre-configures a workspace ready to go:
```bash
cd ~/ansible-lab
```

Inside this directory:
- `ansible.cfg`: Pre-configured default settings (host key checking disabled, yaml callback).
- `inventory.ini`: Pre-populated with `[control]`, `[webservers]`, `[dbservers]`, and `[targets]`.
- `playbooks/`: Starter playbooks for immediate practice.

### 3. Test Connectivity (Ansible Ping)
Run the ad-hoc ping command:
```bash
ansible all -m ping
```
*Expected output:* All nodes (`control-node`, `target-1`, `target-2`) will report `"ping": "pong"` and `SUCCESS`.

### 4. Run Sample Playbooks
```bash
# 1. Ping test playbook
ansible-playbook playbooks/01-ping.yml

# 2. Gather facts from target machines
ansible-playbook playbooks/02-gather-facts.yml

# 3. Install and start Nginx on webservers (target-1)
ansible-playbook playbooks/03-install-nginx.yml
```

Verify Nginx on `target-1` by curling it from the controller:
```bash
curl http://192.168.56.11
```

---

## 🛠️ Handy Vagrant Commands

| Command | Action |
| :--- | :--- |
| `vagrant status` | Check status of all 3 VMs |
| `vagrant ssh control-node` | SSH into the controller |
| `vagrant ssh target-1` | SSH into target-1 |
| `vagrant ssh target-2` | SSH into target-2 |
| `vagrant halt` | Gracefully shut down all VMs |
| `vagrant up` | Start up all VMs |
| `vagrant reload --provision` | Restart and re-run provisioning scripts |
| `vagrant destroy -f` | Completely delete all VMs to free up disk space |
