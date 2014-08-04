VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.6.3"

plugins = Array.new
plugins.push("vagrant-hostmanager")
plugins.push("vagrant-vbguest")
plugins.push("nugrant")
plugins.push("vagrant-triggers")

plugins.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    raise plugin + ' is not installed!' + ' Run the command "vagrant plugin install ' + plugin + '" to install the plugin.'
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.user.defaults = {
    "vm" => {
      "name" => "dockerhost",
      "ip" => "192.168.56.2"
    }
  }
  vm_name = config.user.vm.name
  config.vm.box = "tobiasb/dockerhost"
  config.vm.network :private_network, :ip => config.user.vm.ip
  config.vm.hostname = vm_name + ".dev"
  config.vm.provision :shell , run: "always" do |s|
    s.path = "rbprovisioner/start.sh"
    s.keep_color = true
  end
  config.vm.provider :virtualbox do |vb|
    # Don't boot with headless mode
    vb.name = vm_name
    vb.gui = true
  end
  config.hostmanager.enabled = false
  config.hostmanager.manage_host = true

  [:up, :provision].each do | command |
    config.trigger.after command, :stdout => true do
      setSSHConfig(config)
    end
  end

  def setHostNames(config)
    dirname = File.dirname(__FILE__)
    vhostsfile = dirname + "/vhosts.txt"
    hostnames = Array.new
    if File.exist?(vhostsfile)
      file = File.open(vhostsfile, "r")
      hostnames = file.read.split(" ")
      file.close
    end

    unless hostnames.empty?
      config.hostmanager.aliases = hostnames
      config.vm.provision :hostmanager, run: "always"
    end
  end

  setHostNames(config)

  def setSSHConfig(config)
    vm_name = config.user.vm.name
    dirname = File.dirname(__FILE__)
    dockerSSHConfigFile = dirname + "/ssh_config.txt"
    userSSHConfigFile = ENV["HOME"] + "/.ssh/config"
    if File.exist?(dockerSSHConfigFile)

        file = File.open(dockerSSHConfigFile, "r")
        dockerSSHConfig = file.read
        file.close
        userSSHConfig=""
        if File.exist?(userSSHConfigFile)
          file = File.open(userSSHConfigFile, "r")
          userSSHConfig = file.read
          file.close
        else
          file = File.open(userSSHConfigFile, "w")
          file.write("")
          file.close()
        end
        sshConfigEntry = "#START Docker vbox #{vm_name}\n#{dockerSSHConfig}#END Docker vbox #{vm_name}"
        regex = "#START Docker vbox #{vm_name}(.*)#END Docker vbox #{vm_name}"
        if !userSSHConfig.match(/#{regex}/m)
          file = File.open(userSSHConfigFile, "a")
          file.write("\n\n" + sshConfigEntry)
        else
          file = File.open(userSSHConfigFile, "w")
          file.write(userSSHConfig.sub(/#{regex}/m, sshConfigEntry))
        end
        puts "Added SSH config to #{userSSHConfigFile}"
        file.close()
    end
  end
end
