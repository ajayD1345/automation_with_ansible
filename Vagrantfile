# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
 config.vm.box = "debian/bullseye64"
 config.vm.define "master" do |master|
  master.vm.hostname = "master"
  master.vm.network "public_network", ip: "192.168.8.134"
 master.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = "1"
   end
 master.vm.provision "shell", inline: <<-SHELL
    ssh_config_file="/etc/ssh/sshd_config"
    sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' "$ssh_config_file"
    sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$ssh_config_file"
    sudo systemctl restart ssh || sudo service ssh restart
    sudo apt-get install -y avahi-daemon
    SHELL
   master.vm.provision "shell", path: "./ansible-playbook/deploy.sh"
  end
 end
#Vagrant.configure("2") do |config|
 #config.vm.box = "centos/7"
# config.vm.define "slave" do |slave|
 #   slave.vm.hostname = "slave"
  #  slave.vm.network "public_network", ip: "192.168.8.135"
   # slave.vm.provider "virtualbox" do |vb|
    #  vb.memory = "1024"
     # vb.cpus = "1"
   # end
# slave.vm.provision "shell", inline: <<-SHELL
 #   ssh_config_file="/etc/ssh/sshd_config"
  #  sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' "$ssh_config_file"
   # sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$ssh_config_file"
    #sudo systemctl restart ssh || sudo service ssh restart
     #sudo yum install -y avahi
      #sudo systemctl start avahi-daemon
      #sudo systemctl enable avahi-daemon
    #SHELL
  #end
 #end

