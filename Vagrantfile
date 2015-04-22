# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_version ">= 1.7.0"

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
  end

  # Uchiwa
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  # Grafana
  config.vm.network :forwarded_port, guest: 4000, host: 4000
  # RabbitMQ
  config.vm.network :forwarded_port, guest: 5671, host: 5671
  # InfluxDB
  config.vm.network :forwarded_port, guest: 8083, host: 8083
  config.vm.network :forwarded_port, guest: 8086, host: 8086

  config.vm.synced_folder ".", "/vagrant"
  config.vm.provision :shell do |shell|
    shell.inline =<<-EOC
    apt-get update && apt-get install wget curl git apparmor python -y
    # Setup initial Docker
    wget -qO- https://get.docker.com/ | sh
    # Docker Compose
    curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    EOC
  end
end
