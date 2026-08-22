# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Base box definition (Debian 12 Bookworm - Lightweight & Fast)
  # generic/debian12 officially supports Hyper-V, Libvirt, and VirtualBox
  config.vm.box = "generic/debian12"

  # Target Nodes Definitions (Minimum Specs: 1 vCPU, 512 MB RAM)
  TARGET_NODES = [
    { name: "target-1", ip: "192.168.56.11", cpu: 1, mem: 512 },
    { name: "target-2", ip: "192.168.56.12", cpu: 1, mem: 512 }
  ]

  # Provision Target Nodes
  TARGET_NODES.each do |node|
    config.vm.define node[:name] do |target|
      target.vm.hostname = node[:name]
      target.vm.network "private_network", ip: node[:ip]

      # VirtualBox Provider Settings
      target.vm.provider "virtualbox" do |vb|
        vb.name = "ansible-#{node[:name]}"
        vb.cpus = node[:cpu]
        vb.memory = node[:mem]
        vb.linked_clone = true if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')
      end

      # Libvirt (KVM/QEMU for WSL2) Provider Settings
      target.vm.provider "libvirt" do |lv|
        lv.cpus = node[:cpu]
        lv.memory = node[:mem]
      end

      # Hyper-V Provider Settings (Windows Native Hyper-V)
      target.vm.provider "hyperv" do |h|
        h.vmname = "ansible-#{node[:name]}"
        h.cpus = node[:cpu]
        h.memory = node[:mem]
      end

      # Provisioning
      target.vm.provision "shell", path: "scripts/common.sh"
      target.vm.provision "shell", path: "scripts/setup-target.sh"
    end
  end

  # Provision Ansible Control Node (Minimum Specs: 1 vCPU, 1024 MB RAM)
  config.vm.define "control-node" do |control|
    control.vm.hostname = "control-node"
    control.vm.network "private_network", ip: "192.168.56.10"

    # VirtualBox Provider Settings
    control.vm.provider "virtualbox" do |vb|
      vb.name = "ansible-control-node"
      vb.cpus = 1
      vb.memory = 1024
      vb.linked_clone = true if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')
    end

    # Libvirt (KVM/QEMU for WSL2) Provider Settings
    control.vm.provider "libvirt" do |lv|
      lv.cpus = 1
      lv.memory = 1024
    end

    # Hyper-V Provider Settings (Windows Native Hyper-V)
    control.vm.provider "hyperv" do |h|
      h.vmname = "ansible-control-node"
      h.cpus = 1
      h.memory = 1024
    end

    # Provisioning
    control.vm.provision "shell", path: "scripts/common.sh"
    control.vm.provision "shell", path: "scripts/setup-controller.sh"
  end

end
