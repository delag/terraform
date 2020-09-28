#! /bin/bash

# Variables
#NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
#NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'
NGINX_SERVER_BLOCK='/etc/nginx/nginx.conf'
WEB_DIR='/var/www'
WEB_USER='www-data'
USER='dlg'
NGINX_SCHEME='$scheme'
NGINX_REQUEST_URI='$request_uri'

sudo apt-get -y update
wait 2
sudo apt-get -y install nginx apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
wait 2
sudo apt-get -y update
wait 2
sudo apt install docker-ce -y
wait 2
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
wait 2
cat >docker-compose.yml <<EOF
version: '2'
services:
  httpbin:
    image: "kennethreitz/httpbin"
    ports:
      - "8000:80"
EOF
sudo cp -ia $NGINX_SERVER_BLOCK{,.orig}
wait 1
sudo cat >temp <<EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
        # multi_accept on;
}

http {

        ##
        # Basic Settings
        ##

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        # server_tokens off;

        # server_names_hash_bucket_size 64;
        # server_name_in_redirect off;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ##
        # SSL Settings
        ##

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        ##
        # Logging Settings
        ##

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        ##
        # Gzip Settings
        ##

        gzip on;

        # gzip_vary on;
        # gzip_proxied any;
        # gzip_comp_level 6;
        # gzip_buffers 16 8k;
        # gzip_http_version 1.1;
        # gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

        ##
        # Virtual Host Configs
        ##
	server {
	    listen       80;
	    server_name  _;
	    location / {
	        proxy_pass http://127.0.0.1:8000;
	        index  index.html index.htm;
	    }
	    error_page   500 502 503 504  /50x.html;
	    location = /50x.html {
	        root   /usr/share/nginx/html;
	    }
	}
}
EOF
wait 1
sudo mv temp $NGINX_SERVER_BLOCK
wait 1
rm temp
sudo docker-compose up -d
wait 5
sudo systemctl restart nginx
wait 5
