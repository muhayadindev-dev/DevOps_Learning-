#!/bin/bash
set -e
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
systemctl enable --now nginx
echo '<h1>THREADX public EC2 test</h1>' > /var/www/html/index.html
