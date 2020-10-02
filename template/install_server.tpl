#!/bin/bash
set -e
echo "=====  Installing Nginx ====="
sudo yum update -y
sudo yum install nginx -y
echo '${web_zone}' > /usr/share/nginx/html/index.html
sudo systemctl enable nginx
sudo systemctl restart nginx
echo "=====  Install Complete! ====="
