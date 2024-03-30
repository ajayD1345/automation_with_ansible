#!/bin/bash

# Check if the script is being run as root, if not run as root
if [[ "$(id -u)" -ne 0 ]]; then
    sudo -E "$0" "$@"
    exit
fi

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

# for centos
if [ -x "$(command -v yum)" ]; then
    sudo yum install -y epel-release
    sudo yum install -y yum-utils
    sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    sudo yum-config-manager --enable remi-php82
    sudo yum update -y
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

# for centos
sudo yum install -y gnupg

# Update the PHP repository URL to a valid one for your system
sudo add-apt-repository -y ppa:ondrej/php
suo add-yum-repository -y ppa:ondrej/php

# Install PHP
echo "Installing PHP"
if [ -x "$(command -v apt-get)" ]; then
# Install PHP and necessary extensions for Debian/Ubuntu
sudo apt-get install  php8.2 libapache2-mod-php8.2 php8.2-common php8.2-mysql php8.2-gmp php8.2-curl php8.2-intl php8.2-mbstring php8.2-xmlrpc php8.2-gd php8.2-xml php8.2-cli php8.2-zip php8.2-tokenizer php8.2-bcmath php8.2-soap php8.2-imap unzip zip
elif [ -x "$(command -v yum)" ]; then
    sudo yum install -y php php-common php-mysqlnd php-gmp php-curl php-intl php-mbstring php-json php-xml
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
    sudo apt-get install -y mysql-server
elif [ -x "$(command -v yum)" ]; then
 sudo yum install -y mariadb-server
    sudo systemctl start mariadb
    sudo systemctl enable mariadb
    sudo mysql_secure_installation <<EOF

y
$mysql_root_password
$mysql_root_password
y
y
y
y
EOF
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
# for centos
sudo tee /etc/httpd/conf.d/laravel.conf > /dev/null <<EOL
<VirtualHost *:80>
    ServerAdmin $server_admin_email
    ServerName $server_ip
    DocumentRoot /var/www/html/laravel/public

    <Directory /var/www/html/laravel>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/httpd/error.log
    CustomLog /var/log/httpd/access.log combined
</VirtualHost>
EOL
# Restart Apache web server
echo " Restarting Apache web server "
sudo systemctl restart apache2
sudo systemctl restart httpd

# Disable the default Apache configuration file
echo " Disabling the default Apache configuration file "
sudo a2dissite 000-default.conf
sudo mv /etc/httpd/conf.d/00-default.conf /etc/httpd/conf.d/00-default.conf.disabled
# Restart Apache web server
echo " Restarting Apache web server "
sudo systemctl restart apache2
sudo systemctl restart httpd
# Enable the new Laravel configuration file
echo " Enabling the new Laravel configuration file "
sudo a2enmod rewrite
sudo a2ensite laravel.conf
# for centos
sudo cp /var/www/html/laravel/public/laravel.conf /etc/httpd/conf.d/
# Restart Apache web server
echo " Restarting Apache web server "
sudo systemctl restart apache2
sudo systemctl restart httpd

# Enable the PHP module in Apache
echo " Enabling the PHP module in Apache "
sudo a2enmod php8.2

# Restart Apache web server
echo " Restarting Apache web server "
sudo systemctl restart apache2

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install git if it is not already installed and update it to the latest version
echo "Installing git..."
if command_exists git; then
  echo "Git is already installed. Checking for updates..."
  sudo apt-get update
  sudo apt-get install --only-upgrade git
else
  echo "Git is not installed. Installing the latest version..."
  sudo apt-get install -y git
fi

# Set up Laravel application
echo "Setting up Laravel application..."

# Install Composer
echo "Installing Composer..."
sudo apt-get install curl
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Navigate to the web root directory
echo "Navigating to the web root directory..."
sudo chmod -R ug+w /var/www/html
sudo chown -R vagrant:vagrant /var/www/html
cd /var/www/html || exit

# Clone the Laravel repository from GitHub (replace laravel_repo_url with the actual URL)
echo "Cloning the Laravel repository from GitHub..."
git clone $laravel_repo_url

# Navigate to the Laravel application directory
echo "Navigating to the Laravel application directory..."
cd laravel || exit

# Install the Laravel application dependencies
echo " Installing the Laravel application dependencies "
sudo composer install --no-interaction --optimize-autoloader --no-dev
sudo composer update --no-interaction --optimize-autoloader --no-dev
# Set Laravel permissions
echo " Setting Laravel permissions "
sudo chown -R www-data:www-data /var/www/html/laravel
sudo chmod -R 755 /var/www/html/laravel
sudo chmod -R 755 /var/www/html/laravel/storage
sudo chmod -R 755 /var/www/html/laravel/bootstrap/cache

# Create a new .env file from the .env.example file
echo " Creating a new .env file from the .env.example file "
cp .env.example .env

# Generate an application key
echo " Generating an application key "
 sudo php artisan key:generate

# Mysql Database Setup
echo " Database Setup "
db_name="laravel"
mysql_user="root"

mysql -u $mysql_user -p"$mysql_root_password" <<MYSQL_SCRIPT
CREATE DATABASE $db_name;
GRANT ALL PRIVILEGES ON $db_name.* TO '$mysql_user'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Update the .env file with the database connection details
echo " Updating the .env file with the database connection details "
sudo sed -i "s/DB_PASSWORD=.*/DB_PASSWORD='$mysql_root_password'/" .env

# Cache the configuration values
echo " Caching the configuration values "
sudo php artisan config:cache

# Run the database migrations
echo " Running the database migrations "
sudo php artisan migrate --force

# Restart Apache web server
echo " Restarting Apache web server "
sudo systemctl restart apache2

# End logging the script
echo " Deployment ended at $(date) "

# Add firewall rules

#  Check if ufw is installed and active
if ! dpkg -l | grep -q "ufw"; then
    echo "ufw is not installed. Installing..."
    sudo apt-get install -y ufw
    echo "ufw installed."
fi

# Enable ufw
echo " Enabling ufw...... "
sudo ufw --force enable

echo " Adding firewall rules..... "
sudo ufw allow openssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3306/tcp

# Access the application in a browser using the server IP address
echo " Access the application in a browser using the server IP address...... "
echo " Server IP address: $server_ip.... "























