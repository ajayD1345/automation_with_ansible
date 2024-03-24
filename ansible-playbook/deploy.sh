#!/bin/bash 

shared_dir="/vagrant"
log_file="$shared_dir/deploy.log"
errorlog_file="$shared_dir/deployerror.log"

# Redirecting stdout to log file
exec > >(tee -a "$log_file")

# Redirecting stderr to error log file
exec 2> >(tee -a "$errorlog_file")

# Get server IP address
server_ip=$(ip addr show eth1 | awk '/inet / {print $2}' | cut -d/ -f1)

# Define variables for configurations
server_admin_email="hamedayojide58@gmail.com"
laravel_repo_url="https://github.com/laravel/laravel.git"

# start logging the script
echo "deployment starts $(date)"

# Add important repositories to the APT package manager
echo " Adding important repositories to the APT package manager"
apt-get install -y software-properties-common
add-apt-repository -y ppa:ondrej/php

# Update/Upgrade the package list to ensure you download the latest versions of the packages
echo " Updating the package list "
sudo apt-get update -y
sudo yum update -y
echo " Upgrading the installed packages "
sudo apt-get upgrade -y
sudo yum upgrade -y

# Install and setup AMP (Apache, MySQL, PHP) and other packages


