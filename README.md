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

| Node Name | Role | OS | IP Address | User / Password | Specs |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `control-node` | Ansible Controller | Debian 12 (Bookworm) | `192.168.56.10` | `vagrant` / `vagrant`<br>`ansible` / `ansible` | 2 vCPU, 2GB RAM |
| `target-1` | Managed Target 1 | Debian 12 (Bookworm) | `192.168.56.11` | `vagrant` / `vagrant`<br>`ansible` / `ansible` | 1 vCPU, 1GB RAM |
| `target-2` | Managed Target 2 | Debian 12 (Bookworm) | `192.168.56.12` | `vagrant` / `vagrant`<br>`ansible` / `ansible` | 1 vCPU, 1GB RAM |

---

## ⚡ Automated Host Setup Script

Your host machine **only** needs Vagrant and Virtualization to spin up the VMs. All Ansible tools are automatically installed and isolated inside the `control-node` VM.

### 🐧 Host Machine Setup (1-Command)
Inside your host terminal:
```bash
chmod +x setup-env.sh
./setup-env.sh
```
*This installs Vagrant, KVM/Libvirt, the `vagrant-libvirt` plugin, and configures virtualization services.*

Then launch the lab:
```bash
vagrant up --provider=libvirt
# or if VirtualBox is installed: vagrant up --provider=virtualbox
```

---

### 🪟 Option 2: Windows Host
Open **PowerShell as Administrator** in this directory:
```powershell
.\setup-windows.ps1
```
*This checks/installs Vagrant, checks Hyper-V & VirtualBox availability, and ensures OpenSSH is ready.*

Then launch the lab:
```powershell
vagrant up --provider=hyperv
# or: vagrant up --provider=virtualbox
```

---

## 💻 Option B: Running on Windows Host (VirtualBox)

If you prefer standard VirtualBox on Windows:

1. Install [VirtualBox](https://www.virtualbox.org/) and [Vagrant for Windows](https://developer.hashicorp.com/vagrant/install).
2. Open **PowerShell** or **Windows Terminal** in this project directory:
   ```powershell
   vagrant up --provider=virtualbox
   ```

---

## 🪟 Option C: Running on Windows Host (Hyper-V)

If you have Hyper-V enabled on Windows (Windows Pro/Enterprise/Education):

1. Make sure Hyper-V is enabled in Windows Features.
2. Open **PowerShell as Administrator** in this project directory.
3. Launch the lab with Hyper-V provider:
   ```powershell
   vagrant up --provider=hyperv
   ```
   *(Note: Hyper-V requires Administrator privileges to configure virtual switches).*

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
