# -*- mode: ruby -*-
# vi: set ft=ruby :

plugins = Array.new
plugins.push("vagrant-hostsupdater")
plugins.push("vagrant-vbguest")

plugins.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    raise plugin + ' is not installed!' + ' Run the command "vagrant plugin install ' + plugin + '" to install the plugin.'
  end
end

require 'erb'
require 'yaml'

$nginx_vhost = <<HOST
server {
  listen 80;
  server_name <%= project["server_name"] %> <%= project["server_name_alias"] %>;

  location / {
    proxy_pass http://localhost:<%= project["port"] %>;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
HOST

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Load a projects file if it exists, see projects.example.yml.
  dirname = File.dirname(__FILE__)
  projectsfile = dirname + "/projects.yml"
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "dockerbase"
  config.vm.box_url = "https://dl.dropboxusercontent.com/1/view/3al3t8xxp131w9h/VirtualBox/packer_virtualbox-iso_virtualbox.box"
  hostnames = Array.new
  if File.exist?(projectsfile)
    config.vm.provision :shell, :inline => "/usr/bin/apt-get install -yqq nginx"
    projects = YAML.load_file(projectsfile)
    config.vm.provision "docker" do |d|
      projects.each do |project|
        hostnames.push(project["server_name"])
        if !project["server_name_alias"].nil?
          project["server_name_alias"].split(" ").each do |server_name_alias|
            hostnames.push(server_name_alias)
          end
        end
        template = ERB.new $nginx_vhost
        config.vm.provision :shell, :inline => "echo '" + template.result(binding) + "' > /etc/nginx/sites-enabled/" + project["server_name"]
        unless project["image"].nil? || project["image"].empty?
        d.pull_images project["image"]
        d.run project["server_name"],
          image: project["image"],
          cmd: project["cmd"],
          args: "-d --hostname='" + project["server_name"] + "' " + project["args"]
        end
     end
   end
   config.vm.provision :shell, :inline => "service nginx restart"
  end

$script = <<SCRIPT
#!/usr/bin/env bash
sysctl net.ipv4.ip_forward=1
apt-get update -qq
apt-get upgrade -yqq
apt-get autoclean -yqq -y
SCRIPT

  config.vm.provision :shell, :inline => $script

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  #config.vm.network :forwarded_port, guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
   config.vm.network :private_network, ip: "192.168.56.2"
   config.vm.hostname = "docker.dev"
   
  unless hostnames.empty?
    config.hostsupdater.aliases = hostnames
  end
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
  config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
     # Don't boot with headless mode
     vb.name = "dockerbase"
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
