#!/bin/bash
set -e

# Prevent installation prompts
export DEBIAN_FRONTEND=noninteractive

# 1. Update package information
apt-get update -y

# 2. Install Apache, MySQL and PHP
apt-get install -y \
  apache2 \
  mysql-server \
  php \
  libapache2-mod-php \
  php-mysql \
  php-curl \
  php-gd \
  php-mbstring \
  php-xml \
  php-zip \
  curl \
  tar \
  openssl

# 3. Start Apache and MySQL
systemctl enable --now apache2
systemctl enable --now mysql

# 4. Generate a database password
DB_PASSWORD=$(openssl rand -hex 16)

# 5. Create the WordPress database
mysql <<EOF
CREATE DATABASE wordpress;

CREATE USER 'wordpress'@'localhost'
IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON wordpress.*
TO 'wordpress'@'localhost';
EOF

# 6. Download WordPress
cd /tmp
curl -fsSL https://wordpress.org/latest.tar.gz -o wordpress.tar.gz

# 7. Extract WordPress
tar -xzf wordpress.tar.gz

# 8. Copy WordPress into Apache's directory
rm -f /var/www/html/index.html
cp -a wordpress/. /var/www/html/

# 9. Configure WordPress database connection
cd /var/www/html

cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/wordpress/" wp-config.php
sed -i "s/username_here/wordpress/" wp-config.php
sed -i "s/password_here/${DB_PASSWORD}/" wp-config.php

# 10. Set file ownership
chown -R www-data:www-data /var/www/html/

# 11. Restart Apache
systemctl restart apache2
