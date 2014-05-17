# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_version ">= 1.6.2"
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
    include proxy_params;
    proxy_pass http://localhost:<%= project["port"] %>;
  }
}
HOST

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Load a projects file if it exists, see projects.example.yml.
  dirname = File.dirname(__FILE__)
  projectsfile = dirname + "/projects.yml"
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "tobiasb/dockerhost"
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
          args: " --hostname='" + project["server_name"] + "' " + project["args"]
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

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
   config.vm.network :private_network, ip: "192.168.56.2"
   config.vm.hostname = "docker.dev"
   
  unless hostnames.empty?
    config.hostsupdater.aliases = hostnames
  end

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true
  config.vm.provider :virtualbox do |vb|
     # Don't boot with headless mode
     vb.name = "dockerhost_dev"
     vb.gui = true
     vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
     vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
     vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
end
