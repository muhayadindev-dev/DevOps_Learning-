#!/bin/bash
# Reconstructed Ubuntu example for replaying a public-EC2 web-server check.
# NOT presented as the original Assignment 1 launch user-data.
# Requires a subnet with working outbound package access.
set -e
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
systemctl enable --now nginx
echo '<h1>THREADX public EC2 test</h1>' > /var/www/html/index.html
