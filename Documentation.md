# Project Documentation

## Table of Contents

1. [Introduction](#introduction)
2. [Project Overview](#project-overview)
   - [Objective](#objective)
   - [Requirements](#requirements)
3. [Deployment Instructions](#deployment-instructions)
   - [Provisioning Servers with Vagrant](#provisioning-servers-with-vagrant)
   - [Automating Deployment with Bash Script](#automating-deployment-with-bash-script)
   - [Executing the Ansible Playbook](#executing-the-ansible-playbook)
4. [Code Files](#code-files)
   - [Vagrant Configuration File - Vagrantfile](#vagrant-configuration-file---vagrantfile)
   - [Bash Script - deploy.sh](#bash-script---deploysh)
   - [Ansible Playbook - playbook.yml](#ansible-playbook---playbookyml)
   - [Ansible Configuration - ansible.cfg](#ansible-configuration---ansiblecfg)
   - [Ansible Inventory - inventory.ini](#ansible-inventory---inventoryini)
5. [Log Files](#log-files)
   - [Bash Script Log - deploy.log](#bash-script-log---deploylog)
   - [Ansible Playbook Log - ansible.log](#ansible-playbook-log---ansiblelog)
   - [Cron Job Log - uptime.log](#cron-job-log---uptimelog)
6. [Screenshots](#screenshots)
   - [Screenshot of the Master node on virtualbox](#screenshot-of-the-master-node-on-virtualbox)
   - [Screenshots of the laravel application deployed with Bash script on the Master](#screenshots-of-the-laravel-application-deployed>
   - [Screenshot of the Slave node on virtualbox](#screenshot-of-the-slave-node-on-virtualbox)
- [Screenshot of the Slave node on virtualbox](#screenshot-of-the-slave-node-on-virtualbox)
   - [Screenshot of Playbook execution](#screenshot-of-playbook-execution)
   - [Screenshots of the laravel application deployed with Ansible on the Slave](#screenshots-of-the-laravel-application-deployed-with>
   - [Screenshot of the cronjob](#screenshot-of-the-cronjob)
7. [Usage](#usage)
8. [Important Notes](#important-notes)
9. [Contributing](#contributing)
10. [References](#references)

## [Introduction](introduction)

Welcome to the documentation for the Star Fish project (Deploy LAMP Stack). This documentation provides a comprehensive guide to autom>

## [Project Overview](project-overview)

### [Objective](objective)

The primary objective of this project is to automate the provisioning of two Ubuntu-based servers, referred to as "Master" and "Slave,>

1. Create a bash script to automate the deployment of a LAMP stack on the "Master" node.
2. Clone a PHP application from GitHub.
3. Install all necessary packages.
4. Configure the Apache web server and MySQL.
5. Ensure the bash script is reusable and readable.

In addition to the bash script, an Ansible playbook is used to:
1. Execute the bash script on the "Slave" node.
2. Create a cron job to check the server's uptime every day at midnight.

It is also important to verify that the PHP application is accessible through the VM's IP address and take a screenshot as evidence.

### [Requirements](requirements)

To complete the project, the following requirements must be met:

1. Submit the bash script and Ansible playbook to a publicly accessible GitHub repository.
2. Document the steps in Markdown files, including screenshots where necessary.
3. Use either the VM's IP address or a domain name as the URL.

## [Deployment Instructions](deployment-instructions)

In this section, we'll cover the steps to deploy the LAMP stack using Vagrant, the bash script, and the Ansible playbook.

### [Provisioning Servers with Vagrant](provisioning-servers-with-vagrant)

To provision servers using Vagrant, we use the `Vagrantfile` provided. This file defines the configuration for both the "Master" and ">

1. **Vagrant Configuration File**: The `Vagrantfile` specifies the configuration for the "Master" and "Slave" servers.

```ruby
# Deployment of two Ubuntu-based servers, named Master and Slave using Vagrant.
Vagrant.configure("2") do |config|
  # Configuration for Master server
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.define "Master" do |master|
    # Master server settings
    # ...
  end

  # Configuration for Slave server
  config.vm.define "Slave" do |slave|
    # Slave server settings
    # ...
  end
end
```

2. **Server Provisioning**: The Vagrant configuration provisions the servers and ensures that SSH is properly configured. It also exec>

3. **Network Configuration**: The servers are connected to a private network to allow communication between them.

Detailed instructions for provisioning servers using Vagrant can be found in the provided [Vagrant Configuration File - Vagrantfile](#>

### [Automating Deployment with Bash Script](automating-deployment-with-bash-script)

The `deploy.sh` script automates the deployment of the LAMP stack. It performs the following tasks:
1. Add important repositories to the APT package manager.
2. Updates and upgrades installed packages.
3. Installs Apache, MySQL, PHP, and other necessary packages.
4. Configures Apache for a Laravel application.
5. Installs Composer and sets permissions.
6. Clones the Laravel application from GitHub and configures it.
7. Set up the MySQL database and update the `.env` file.
8. Caches configuration values and runs database migrations.

The script also adds firewall rules to allow necessary ports.

The `deploy.sh` script is thoroughly documented in the

- [deploy.sh](#bash-script---deploysh)

### [Executing the Ansible Playbook](executing-the-ansible-playbook)

The Ansible playbook, `playbook.yml`, automates the execution of the `deploy.sh` script on the "Slave" server and sets up a cron job t>

1. **Copying Deployment Script**: The playbook copies the `deploy.sh` script to the "Slave" server.

2. **Executing Deployment Script**: It then executes the script and logs the output.

3. **Permissions and Cron Job**: The playbook ensures correct permissions for directories and creates a cron job to check the server's>

The Ansible playbook and its configurations are documented in the

- [Ansible Playbook - playbook.yml](#ansible-playbook---playbookyml)

- [Ansible Configuration - ansible.cfg](#ansible-configuration---ansiblecfg)

- [Ansible Inventory - inventory.ini](#ansible-inventory---inventoryini)

## [Code Files](code-files)

In this section, we provide the content of the code files used in the project.

### [Vagrant Configuration File - Vagrantfile](vagrant-configuration-file---vagrantfile)

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Deployment of two Ubuntu-based servers, named Master and Slave using Vagrant.

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.define "Master" do |master|
    master.vm.hostname = "Master"
    master.vm.network "private_network", ip: "192.168.56.20"
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
  config.vm.define "Slave" do |slave|
    slave.vm.hostname = "Slave"
    slave.vm.network "private_network", ip: "192.168.56.21"
    slave.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "2"
    end
    slave.vm.provision "shell", inline: <<-SHELL
      ssh_config_file="/etc/ssh/sshd_config"
      sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' "$ssh_config_file"
      sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$ssh_config_file"
      sudo systemctl restart ssh || sudo service ssh restart
      sudo apt-get install -y avahi-daemon
  SHELL
  end
end
```

### [Bash Script - deploy.sh](bash-script---deploysh)

```bash
#!/bin/bash

# This script will automatically deploy a LAMP stack and clone a PHP application from a GitHub repository (https://github.com/laravel/>

# Check if the script is being run as root, if not run as root
if [[ "$(id -u)" -ne 0 ]]; then
    sudo -E "$0" "$@"
    exit
fi

# Log all the commands and the output to a file called deploy.log in the shared directory
shared_dir="/vagrant"
log_file="$shared_dir/deploy.log"
exec > >(tee -a "$log_file") 2>&1

# Get server IP address
server_ip=$(ip addr show eth1 | awk '/inet / {print $2}' | cut -d/ -f1)

