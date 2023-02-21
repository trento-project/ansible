Vagrant.require_version ">= 1.8.0"

Vagrant.configure(2) do |config|

  config.vm.box = "opensuse/Leap-15.3.x86_64"
  config.vm.provision "ansible" do |ansible|
    # ansible.verbose = "v"
    ansible.playbook = "playbook.yml"
  end
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
  end
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 80, host: 8080
end