#!/bin/bash
# THREADX App 2 — user data captured from the EC2 launch configuration.
# Amazon Linux dnf installation. Intended for first boot via EC2 user data.
set -e
dnf install -y nginx
systemctl enable --now nginx
echo "<h1>Welcome to THREADX Online Clothing Store - EC2 Application 2</h1>" > /usr/share/nginx/html/index.html
