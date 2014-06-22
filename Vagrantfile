VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.6.3"

plugins = Array.new
plugins.push("vagrant-hostsupdater")
plugins.push("vagrant-vbguest")
plugins.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    raise plugin + ' is not installed!' + ' Run the command "vagrant plugin install ' + plugin + '" to install the plugin.'
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
#  config.ssh.forward_agent = true
  config.vm.box = "tobiasb/dockerhost"
  config.vm.network :private_network, ip: "192.168.56.2"
  config.vm.hostname = "dockerproxy.dev"
  config.vm.provision :shell do |s|
    s.path = "rbprovisioner/start.sh"
    s.keep_color = true
  end
  config.vm.provider :virtualbox do |vb|
     # Don't boot with headless mode
     vb.name = "dockerproxy"
     vb.gui = true
  end
end
