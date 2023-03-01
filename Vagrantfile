Vagrant.require_version ">= 1.8.0"

Vagrant.configure(2) do |config|

  config.vm.box = "opensuse/Leap-15.3.x86_64"
  config.vm.provision "ansible" do |ansible|
    # ansible.verbose = "v"
    ansible.playbook = "playbook.yml"
    ansible.extra_vars = {
      web_postgres_password: "pass",
      wanda_postgres_password: "wanda",
      rabbitmq_password: "trento",
      runner_url: "http://localhost",
      prometheus_url: "http://localhost",
      web_admin_password: "adminpassword",
      trento_server_name: "trento.local trento.local:8080"
    }
  end
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
  end
  config.vm.network "forwarded_port", guest: 80, host: 8080
end