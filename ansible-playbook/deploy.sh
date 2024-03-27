##!/bin/bash 

#shared_dir="/vagrant"
#log_file="$shared_dir/deploy.log"
#errorlog_file="$shared_dir/deployerror.log"

# Redirecting stdout to log file
#exec > >(tee -a "$log_file")

# Redirecting stderr to error log file
#exec 2> >(tee -a "$errorlog_file")

# Get server IP address
#server_ip=$(ip addr show eth1 | awk '/inet / {print $2}' | cut -d/ -f1)

# Define variables for configurations
#server_admin_email="hamedayojide58@gmail.com"
#laravel_repo_url="https://github.com/laravel/laravel.git"

# start logging the script
#echo "deployment starts $(date)"

# Add important repositories to the APT package manager
#echo " Adding important repositories to the APT package manager"
#sudo apt-get install -y software-properties-common
#sudo add-apt-repository -y ppa:ondrej/php

# Update/Upgrade the package list to ensure you download the latest versions of the packages
#echo " Updating the package list "
#sudo apt-get update -y
#sudo yum update -y
#echo " Upgrading the installed packages "
#sudo apt-get upgrade -y
#sudo yum upgrade -y

# Install and setup AMP (Apache, MySQL, PHP) and other packages

# install apache2 on server
#echo " Installing apache services on servers... "
#sudo apt-get install  -y apache2
#sudo yum install -y httpd

# start and enable apache services
#echo "enabling apache services"
# For debian/ubuntu
#sudo systemctl start apache2
#sudo systemctl enable apache2
# For CentOs
#sudo systemctl enable httpd
#sudo systemctl start httpd

# Install PHP and some of the most common PHP extensions
#echo " Installing PHP and some of the most common PHP extensions "
#sudo apt-get install -y php8.2 libapache2-mod-php8.2 php8.2-common php8.2-mysql php8.2-gmp php8.2-curl php8.2-intl php8.2-mbstring php8.2-xmlrpc php8.2-gd php8.2-xml php8.2-cli php8.2-zip php8.2-tokenizer php8.2-bcmath php8.2-soap php8.2-imap unzip zip
# For centos
#sudo yum install php php-mysql php-gd php-json php-xml

# Configure PHP
#echo " Configuring PHP "
#sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.2/apache2/php.ini
# For CentOs
#sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php.ini

# Restart apache server
#echo "Restarting apache server"
#sudo systemctl restart apache2
# For CentOs
#$sudo systemctl restart httpd

# Generate a random secure password for MySQL root user
#echo " Generating a random secure password for MySQL root user "
#mysql_root_password=$(openssl rand -base64 12)

# Install MySQL Server in a Non-Interactive mode. Default root password will be set to the one you set in the previous step
#echo " Installing MySQL Server "
#sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_root_password"
#sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_root_password"
#sudo apt-get install -y mysql-server
# For CentOS
#echo "Installing MySQL Server" && sudo yum install -y mysql-server && echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$mysql_root_password';" | sudo mysql -u root && echo -e "\n\n\n\n$mysql_root_password\n$mysql_root_password\nY\nY\nY\nY" | sudo mysql_secure_installation

# Display the MySQL root password
#echo " MySQL root password: $mysql_root_password "

# Disallow remote root login
#echo " Disallowing remote root login"
#sudo sed -i "s/.*bind-address.*/bind-address = 127.0.0.1/" /etc/mysql/mysql.conf.d/mysqld.cnf
# For centos
#sudo sed -i 's/.*bind-address.*/bind-address = 127.0.0.1/' /etc/my.cnf

# Remove the test database
#echo " Removing the test database "
# sudo mysql -uroot -p"$mysql_root_password" -e "DROP DATABASE IF EXISTS test;" || true

# Restart Apache web server
#echo " Restarting Apache web server... "
#sudo systemctl restart apache2

#if [ $# -ne 0 ]; then
#echo " something is wrong.."
#else
# echo " works fine.."
#exit
#fi










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

# Start logging the script
echo "Deployment starts $(date)"

# Add important repositories to the APT package manager (for Debian/Ubuntu)
echo "Adding important repositories to the package manager"
if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:ondrej/php
    echo "Updating the package list"
    sudo apt-get update -y
    echo "Upgrading the installed packages"
    sudo apt-get upgrade -y
fi
# Install and setup AMP (Apache, MySQL, PHP) and other packages

# Install Apache
echo "Installing Apache"
if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get install -y apache2
elif [ -x "$(command -v yum)" ]; then
    sudo yum install -y httpd
fi

# Start and enable Apache
echo "Enabling Apache services"
if [ -x "/usr/bin/systemctl" ]; then
    sudo systemctl start apache2 || sudo systemctl start httpd
    sudo systemctl enable apache2 || sudo systemctl enable httpd
fi

# Install gnupg to handle GPG keys
sudo apt-get install -y gnupg

# Update the PHP repository URL to a valid one for your system
sudo add-apt-repository -y ppa:ondrej/php

# Install PHP
echo "Installing PHP"
if [ -x "$(command -v apt-get)" ]; then
# Install PHP and necessary extensions for Debian/Ubuntu
sudo apt-get install php libapache2-mod-php php-mysql
elif [ -x "$(command -v yum)" ]; then
    sudo yum install -y php php-mysql php-gd php-json php-xml
fi

# Configure PHP
echo "Configuring PHP"
if [ -f "/etc/php/8.2/apache2/php.ini" ]; then
    sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.2/apache2/php.ini
elif [ -f "/etc/php.ini" ]; then
    sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php.ini
fi

# Restart Apache server
echo "Restarting Apache server"
if [ -x "/usr/bin/systemctl" ]; then
    sudo systemctl restart apache2 || sudo systemctl restart httpd
fi

# Generate a random secure password for MySQL root user
echo "Generating a random secure password for MySQL root user"
mysql_root_password=$(openssl rand -base64 12)

# Install MySQL Server
echo "Installing MySQL Server"
if [ -x "$(command -v apt-get)" ]; then
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_root_password"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_root_password"
    sudo apt-get install default-mysql-server
    #sudo apt-get install -y mysql-server
elif [ -x "$(command -v yum)" ]; then
    sudo yum install -y mysql-server
    sudo systemctl start mysqld
    sudo systemctl enable mysqld
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$mysql_root_password';" | sudo mysql
fi

# Display the MySQL root password
echo "MySQL root password: $mysql_root_password"

# Disallow remote root login
echo "Disallowing remote root login"
if [ -f "/etc/mysql/mysql.conf.d/mysqld.cnf" ]; then
    sudo sed -i "s/.*bind-address.*/bind-address = 127.0.0.1/" /etc/mysql/mysql.conf.d/mysqld.cnf
elif [ -f "/etc/my.cnf" ]; then
    sudo sed -i 's/.*bind-address.*/bind-address = 127.0.0.1/' /etc/my.cnf
fi

# Remove the test database
echo "Removing the test database"
sudo mysql -uroot -p"$mysql_root_password" -e "DROP DATABASE IF EXISTS test;" || true

# Restart Apache web server
echo "Restarting Apache web server"
if [ -x "/usr/bin/systemctl" ]; then
    sudo systemctl restart apache2 || sudo systemctl restart httpd
fi

# Create a new Apache configuration file for Laravel
echo " Creating a new Apache configuration file for Laravel "
sudo tee /etc/apache2/sites-available/laravel.conf > /dev/null <<EOL
<VirtualHost *:80>
    ServerAdmin $server_admin_email
    ServerName $server_ip
    DocumentRoot /var/www/html/laravel/public

    <Directory /var/www/html/laravel>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

# Restart Apache web server
echo " Restarting Apache web server "
sudo systemctl restart apache2

# Disable the default Apache configuration file
echo " Disabling the default Apache configuration file "
sudo a2dissite 000-default.conf

# Restart Apache web server
echo " Restarting Apache web server "
sudo systemctl restart apache2

# Enable the new Laravel configuration file
echo " Enabling the new Laravel configuration file "
sudo a2enmod rewrite
sudo a2ensite laravel.conf

# Restart Apache web server
echo " Restarting Apache web server "
sudo systemctl restart apache2

# Enable the PHP module in Apache
echo " Enabling the PHP module in Apache "
sudo a2enmod php8.2

# Restart Apache web server
echo " Restarting Apache web server "
sudo systemctl restart apache2
