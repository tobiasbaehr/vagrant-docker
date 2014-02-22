# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.require_plugin 'vagrant-hostsupdater'
Vagrant.require_plugin 'vagrant-vbguest'
Vagrant.require_plugin 'vagrant-cachier'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "dockerbase"
  config.cache.auto_detect = true
  config.vm.provision "docker",
    images: ["tobiasb/rb-basic-lamp"]

$script = <<SCRIPT
#!/usr/bin/env bash
sysctl net.ipv4.ip_forward=1
/usr/bin/aptitude update
/usr/bin/aptitude safe-upgrade -y
/usr/bin/aptitude autoclean -y && /usr/bin/aptitude forget-new -y
SCRIPT

  config.vm.provision :shell, :inline => $script

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
   config.vm.network :private_network, ip: "192.168.56.2"
   config.vm.hostname = "docker.dev"
  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
     vb.gui = true
     vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
     vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
     #vb.customize ["modifyhd", "fbd5b996-4838-48a9-9c21-34cb745ff413", "--resize", 100000]
     #override.ssh.private_key_path = '~/.ssh/id_rsa'
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

end
