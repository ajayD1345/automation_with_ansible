# -*- mode: ruby -*-
# vi: set ft=ruby :

# Master node
#Vagrant.configure("2") do |config|
# config.vm.box = "bento/ubuntu-20.04"
# config.vm.define "master" do |master|
#  master.vm.hostname = "master"
#  master.vm.network "public_network", ip: "192.168.8.134"
# master.vm.provider "virtualbox" do |vb|
#    vb.memory = "1024"
#    vb.cpus = "1"
#   end
# master.vm.provision "shell", inline: <<-SHELL
#    ssh_config_file="/etc/ssh/sshd_config"
#    sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' "$ssh_config_file"
#    sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$ssh_config_file"
#    sudo systemctl restart ssh || sudo service ssh restart
#    sudo apt-get install -y avahi-daemon
#    SHELL
#   master.vm.provision "shell", path: "./ansible-playbook/deploy.sh"
#  end
# end

# Slave node
Vagrant.configure("2") do |config|
  # Ubuntu Slave node
  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "bento/ubuntu-20.04"
    ubuntu.vm.hostname = "ubuntu-slave"
    ubuntu.vm.network "public_network", ip: "192.168.8.135"
    ubuntu.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
    end
    ubuntu.vm.provision "shell", inline: <<-SHELL
      ssh_config_file="/etc/ssh/sshd_config"
      sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' "$ssh_config_file"
      sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$ssh_config_file"
      sudo systemctl restart ssh || sudo service ssh restart
      sudo apt-get install -y avahi-daemon
    SHELL
  end

  # CentOS Slave node
  config.vm.define "centos" do |centos|
    centos.vm.box = "centos/7"
    centos.vm.hostname = "centos-slave"
    centos.vm.network "public_network", ip: "192.168.8.136"
    centos.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
    end
    centos.vm.provision "shell", inline: <<-SHELL
      ssh_config_file="/etc/ssh/sshd_config"
      sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' "$ssh_config_file"
      sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$ssh_config_file"
      sudo systemctl restart ssh || sudo service ssh restart
      sudo yum install -y avahi
      sudo systemctl start avahi-daemon
      sudo systemctl enable avahi-daemon
    SHELL
  end
end
