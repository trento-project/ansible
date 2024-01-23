Vagrant.require_version ">= 1.8.0"

Vagrant.configure(2) do |config|
  config.vm.box = "opensuse/Leap-15.4.x86_64"
  config.vm.define "machine1"

  config.vm.provision "ansible" do |ansible|
    # ansible.verbose = "v"
    ansible.playbook = "playbook.yml"
    ansible.groups = {
      "trento-server" => ["machine1"],
      "postgres-hosts" => ["machine1"],
      "prometheus-hosts" => ["machine1"],
      "rabbitmq-hosts" => ["machine1"]
    }
    ansible.extra_vars = {
      web_postgres_password: "pass",
      wanda_postgres_password: "wanda",
      rabbitmq_password: "trento",
      nginx_vhost_filename: "trento.conf",
      prometheus_url: "http://localhost",
      web_admin_password: "adminpassword",
      trento_server_name: "trento.local trento.local:8080",
      nginx_ssl_cert_as_base64: "false",
      nginx_ssl_key_as_base64: "false",
      nginx_ssl_cert: "<ADD YOUR NGINX SSL CERT HERE>",
      nginx_ssl_key: "<ADD YOUR NGINX SSL KEY HERE>"
    }
  end
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
  end
  config.vm.network "forwarded_port", guest: 80, host: 8080
end