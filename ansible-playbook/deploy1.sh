#!/bin/bash

shared_dir="/vagrant"
log_file="$shared_dir/deploy.log"
errorlog_file="$shared_dir/deployerror.log"

# Redirecting stdout to log file
exec > >(tee -a "$log_file")

# Redirecting stderr to error log file
exec 2> >(tee -a "$errorlog_file")

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get server IP address
server_ip=$(ip addr show eth1 | awk '/inet / {print $2}' | cut -d/ -f1)

# Define variables for configurations
server_admin_email="hamedayojide58@gmail.com"
laravel_repo_url="https://github.com/laravel/laravel.git"

# Start logging the script
echo "Deployment starts $(date)"

# Add important repositories to the package manager (for Debian/Ubuntu)
echo "Adding important repositories to the package manager"
if command_exists apt-get; then
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:ondrej/php
    echo "Updating the package list"
    sudo apt-get update -y
    echo "Upgrading the installed packages"
    sudo apt-get upgrade -y
fi

# Install Apache
echo "Installing Apache"
if command_exists apt-get; then
    sudo apt-get install -y apache2
elif command_exists yum; then
    sudo yum install -y httpd
fi

# Start and enable Apache
echo "Enabling Apache services"
if command_exists systemctl; then
    sudo systemctl start apache2 || sudo systemctl start httpd
    sudo systemctl enable apache2 || sudo systemctl enable httpd
elif command_exists service; then
    sudo service apache2 start || sudo service httpd start
    sudo chkconfig apache2 on || sudo chkconfig httpd on
fi

# Install gnupg to handle GPG keys
if command_exists apt-get; then
    sudo apt-get install -y gnupg
fi

# Install PHP
echo "Installing PHP"
if command_exists apt-get; then
    sudo apt-get install -y php8.2 libapache2-mod-php8.2 php8.2-common php8.2-mysql php8.2-gmp php8.2-curl php8.2-intl php8.2-mbstring php8.2-xml php8.2-zip php8.2-ldap php8.2-gd php8.2-bz2 php8.2-sqlite3 php8.2-redis
elif command_exists yum; then
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
if command_exists systemctl; then
    sudo systemctl restart apache2 || sudo systemctl restart httpd
elif command_exists service; then
    sudo service apache2 restart || sudo service httpd restart
fi

# Install MySQL Server
echo "Installing MySQL Server"
if command_exists apt-get; then
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_root_password"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_root_password"
    sudo apt-get install -y default-mysql-server
elif command_exists yum; then
    sudo yum install -y mysql-server
    if command_exists systemctl; then
        sudo systemctl start mysqld
        sudo systemctl enable mysqld
    elif command_exists service; then
        sudo service mysqld start
        sudo chkconfig mysqld on
    fi
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
if command_exists systemctl; then
    sudo systemctl restart apache2 || sudo systemctl restart httpd
elif command_exists service; then
    sudo service apache2 restart || sudo service httpd restart
fi

# End logging the script
echo "Deployment ended at $(date)"
