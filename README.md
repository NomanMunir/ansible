# 🚀 Ansible 3-Node Lab Environment (KodeKloud Course Ready)

This repository sets up a complete, automated 3-node Linux environment for Ansible training using **Vagrant**.

---

## 📐 Lab Architecture & Topology

```text
               +---------------------------+
               |       control-node        |
               |       192.168.77.10       |
               | (Ansible, SSH Key Master) |
               +-------------+-------------+
                             |
              +--------------+--------------+
              |                             |
              v                             v
+---------------------------+ +---------------------------+
|         target-1          | |         target-2          |
|       192.168.77.11       | |       192.168.77.12       |
|    (Group: webservers)    | |    (Group: dbservers)     |
+---------------------------+ +---------------------------+
```

| Node Name | Role | OS | IP Address | User / Password | Specs |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `control-node` | Ansible Controller | Debian 12 (Bookworm) | `192.168.77.10` | `vagrant` / `vagrant`<br>`ansible` / `ansible` | 2 vCPU, 2GB RAM |
| `target-1` | Managed Target 1 | Debian 12 (Bookworm) | `192.168.77.11` | `vagrant` / `vagrant`<br>`ansible` / `ansible` | 1 vCPU, 1GB RAM |
| `target-2` | Managed Target 2 | Debian 12 (Bookworm) | `192.168.77.12` | `vagrant` / `vagrant`<br>`ansible` / `ansible` | 1 vCPU, 1GB RAM |

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

## 🎮 Using the Lab & Following Your Course

### 1. Connect to the Controller Node
```bash
vagrant ssh control-node
```

### 2. Verify Passwordless SSH to Targets
The nodes are configured with passwordless SSH keys. Test connecting to the targets:
```bash
ssh target-1    # should connect without asking for password
exit
ssh target-2    # should connect without asking for password
exit
```

---

## 📚 Step-by-Step Learning Practice (KodeKloud Course)

### Step 1: Install Ansible on `control-node`
```bash
sudo apt update
sudo apt install -y ansible
ansible --version
```

### Step 2: Create your Inventory File
Create an inventory file named `inventory.ini` or `hosts`:
```ini
[webservers]
target-1 ansible_host=192.168.77.11

[dbservers]
target-2 ansible_host=192.168.77.12
```

### Step 3: Test Ad-Hoc Ping Command
```bash
ansible all -i inventory.ini -m ping
```

### Step 4: Write Your First Playbook
Create a test playbook `test.yml`:
```yaml
---
- name: Test Playbook
  hosts: all
  tasks:
    - name: Ping all nodes
      ansible.builtin.ping:
```

Run it:
```bash
ansible-playbook -i inventory.ini test.yml
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
