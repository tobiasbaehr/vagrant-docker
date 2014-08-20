VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.6.3"

# Check required plugins
REQUIRED_PLUGINS = %w(vagrant-hostmanager vagrant-vbguest nugrant)
exit unless REQUIRED_PLUGINS.all? { |plugin|
  Vagrant.has_plugin?(plugin) || (
    puts "The #{plugin} plugin is required. Please install it with:"
    puts "vagrant plugin install #{plugin}"
    false
  )
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.user.defaults = {
    "vm" => {
      "name" => "dockerhost",
      "ip" => "192.168.56.2",
      "memory" => 1024
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
    vb.memory = config.user.vm.memory
  end
  config.hostmanager.enabled = false
  config.hostmanager.manage_host = true

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
