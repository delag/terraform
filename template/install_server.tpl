#!/bin/bash
set -e

sudo -i
setenforce permissive

# Update system and install base components
yum update -y
yum install -y yum-utils jq device-mapper-persistent-data lvm2 nc nginx

# Generate Origin certificate to use for the VM.
openssl req -new -newkey rsa:2048 -nodes -keyout ${web_zone}.key -out ${web_zone}.csr -subj "/C=US/ST=TX/L=CFTest/O=CFtest/CN=*.${web_zone}" 2>/dev/null
cfCSR=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ${web_zone}.csr)
certGenerate=$(curl -sX POST "https://api.cloudflare.com/client/v4/certificates" \
    -H "X-Auth-Email: ${cf_user}" \
    -H "X-Auth-Key: ${cf_api}" \
    --data '{"hostnames":["'"${web_zone}"'","*.'"${web_zone}"'"],"requested_validity":5475,"request_type":"origin-rsa","csr":"'"$cfCSR"'"}')
echo $certGenerate | jq -r .result.certificate > ${web_zone}.crt
mv ${web_zone}.key /etc/pki/tls/private/
mv ${web_zone}.crt /etc/pki/tls/certs/

# Install docker
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose
systemctl start docker.service && systemctl enable docker.service

# Update the nginx config
mv /etc/nginx/nginx.conf{,.orig}
touch /etc/nginx/nginx.conf

cat > /etc/nginx/nginx.conf << 'EOF'
# nginx startup file
user nginx nginx;

#usually equal to number of CPUs you have. run command "grep processor /proc/cpuinfo | wc -l" to find it
worker_processes  1;
worker_cpu_affinity 1;

error_log  /var/log/nginx/error.log;
pid        /run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;

    include            /etc/nginx/mime.types;
    default_type       application/octet-stream;

    sendfile           on;
    keepalive_timeout  65;

        server {
                listen 80 default_server;
                listen [::]:80 default_server;
                server_name  _;
                return 301 https://$host$request_uri;
        }
        server {
                listen 443 ssl http2;
                server_name _;

                access_log /var/log/nginx/$host.log;
                error_log /var/log/nginx/$host.error.log;

                ssl_certificate /etc/pki/tls/certs/${web_zone}.crt;
                ssl_certificate_key /etc/pki/tls/private/${web_zone}.key;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
                ssl_ciphers HIGH:!aNULL:!MD5;

                # Client IPs from Cloudflare
                set_real_ip_from 103.21.244.0/22;
                set_real_ip_from 103.22.200.0/22;
                set_real_ip_from 103.31.4.0/22;
                set_real_ip_from 104.16.0.0/12;
                set_real_ip_from 108.162.192.0/18;
                set_real_ip_from 131.0.72.0/22;
                set_real_ip_from 141.101.64.0/18;
                set_real_ip_from 162.158.0.0/15;
                set_real_ip_from 172.64.0.0/13;
                set_real_ip_from 173.245.48.0/20;
                set_real_ip_from 188.114.96.0/20;
                set_real_ip_from 190.93.240.0/20;
                set_real_ip_from 197.234.240.0/22;
                set_real_ip_from 198.41.128.0/17;
                set_real_ip_from 2400:cb00::/32;
                set_real_ip_from 2606:4700::/32;
                set_real_ip_from 2803:f800::/32;
                set_real_ip_from 2405:b500::/32;
                set_real_ip_from 2405:8100::/32;
                set_real_ip_from 2c0f:f248::/32;
                set_real_ip_from 2a06:98c0::/29;
                # Defining which header sets the client IP
                #real_ip_header X-Forwarded-For;
                real_ip_header CF-Connecting-IP;

                location / {
                        proxy_set_header HOST $http_host;
                        proxy_set_header X-Forwarded-Proto $scheme;
                        proxy_set_header X-Real-IP $remote_addr;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                        proxy_pass http://127.0.0.1:8084;
                }
        }
        include sites-enabled/*;
}
EOF

mkdir /etc/nginx/sites-available/
mkdir /etc/nginx/sites-enabled/
touch /etc/nginx/sites-available/api.${web_zone}.conf
cat > /etc/nginx/sites-available/api.${web_zone}.conf << EOF
server {
	listen 443 ssl http2;
	server_name api.${web_zone};

	access_log /var/log/nginx/api.${web_zone}.log;
	error_log /var/log/nginx/api.${web_zone}.error.log;

	# SSL/TLS
	ssl on;
	ssl_certificate /etc/pki/tls/certs/${web_zone}.crt;
	ssl_certificate_key /etc/pki/tls/private/${web_zone}.key;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	ssl_ciphers HIGH:!aNULL:!MD5;

	# Client IPs from Cloudflare
  set_real_ip_from 103.21.244.0/22;
  set_real_ip_from 103.22.200.0/22;
  set_real_ip_from 103.31.4.0/22;
  set_real_ip_from 104.16.0.0/12;
  set_real_ip_from 108.162.192.0/18;
  set_real_ip_from 131.0.72.0/22;
  set_real_ip_from 141.101.64.0/18;
  set_real_ip_from 162.158.0.0/15;
  set_real_ip_from 172.64.0.0/13;
  set_real_ip_from 173.245.48.0/20;
  set_real_ip_from 188.114.96.0/20;
  set_real_ip_from 190.93.240.0/20;
  set_real_ip_from 197.234.240.0/22;
  set_real_ip_from 198.41.128.0/17;
  set_real_ip_from 2400:cb00::/32;
  set_real_ip_from 2606:4700::/32;
  set_real_ip_from 2803:f800::/32;
  set_real_ip_from 2405:b500::/32;
  set_real_ip_from 2405:8100::/32;
  set_real_ip_from 2c0f:f248::/32;
  set_real_ip_from 2a06:98c0::/29;

  real_ip_header X-Forwarded-For;

  location / {
      proxy_set_header HOST \$http_host;
    	proxy_set_header X-Forwarded-Proto \$scheme;
    	proxy_set_header X-Real-IP \$remote_addr;
    	proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_pass http://127.0.0.1:8080;
  }
}
server {
    if (\$host = api.${web_zone} ) {
        return 301 https://\$host\$request_uri;
    }

    listen 80;

    server_name api.${web_zone};
    return 404;
}
EOF

## Creating server blocks for the containers.
cp /etc/nginx/sites-available/api.${web_zone}.conf{,.orig}
cp /etc/nginx/sites-available/api.${web_zone}.conf.orig /etc/nginx/sites-available/${web_zone}.conf
cp /etc/nginx/sites-available/api.${web_zone}.conf.orig /etc/nginx/sites-available/httpbin.${web_zone}.conf
cp /etc/nginx/sites-available/api.${web_zone}.conf.orig /etc/nginx/sites-available/ghost.${web_zone}.conf
## Changing the config to match the subdomain for the container.
sed -i -e 's/api.//g' /etc/nginx/sites-available/${web_zone}.conf
sed -i -e 's/api/httpbin/g' /etc/nginx/sites-available/httpbin.${web_zone}.conf
sed -i -e 's/api/ghost/g' /etc/nginx/sites-available/ghost.${web_zone}.conf
## And port.
sed -i -e 's/8080/8081/g' /etc/nginx/sites-available/httpbin.${web_zone}.conf
sed -i -e 's/8080/8082/g' /etc/nginx/sites-available/ghost.${web_zone}.conf
sed -i -e 's/8080/8083/g' /etc/nginx/sites-available/${web_zone}.conf
## Symlink the conf files to the location nginx can read them from.
ln -s /etc/nginx/sites-available/*.conf /etc/nginx/sites-enabled/

# Docker configs
### JSON DB file
touch db.json
cat > db.json << EOF
{
  "posts": [
    { "id": 1, "body": "foo" },
    { "id": 2, "body": "bar" }
  ],
  "comments": [
    { "id": 1, "body": "baz", "postId": 1 },
    { "id": 2, "body": "qux", "postId": 2 }
  ]
}
EOF

### Docker Compose File
touch docker-compose.yml
cat > docker-compose.yml << EOF
version: '3'
services:
  api:
    image: clue/json-server
    restart: always
    container_name: json
    ports:
      - 8080:80
    volumes:
      - ./db.json:/data/db.json

  httpbin:
    image: kennethreitz/httpbin
    restart: always
    container_name: httpbin
    ports:
      - 8081:80

  wpdb:
    image: mariadb:latest
    restart: always
    container_name: wpdb
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpUser
      MYSQL_PASSWORD: wordPre22Secur3
      MYSQL_ROOT_PASSWORD: L0KalDbPa22
    expose:
      - "3306"
    volumes:
      - wp-data:/var/lib/mysql

  ghostdb:
    image: mariadb:latest
    restart: always
    container_name: ghostdb
    environment:
      MYSQL_DATABASE: ghost
      MYSQL_USER: ghostUser
      MYSQL_PASSWORD: gH0StSecur3
      MYSQL_ROOT_PASSWORD: L0KalDbPa22
    expose:
      - "3306"
    volumes:
      - ghost-data:/var/lib/mysql

  ghost:
    depends_on:
      - ghostdb
    restart: always
    image: ghost:latest
    container_name: ghost
    ports:
      - 8082:2368
    environment:
      url: https://ghost.${web_zone}
      database_client: mariadb
      database_connection_host: ghostdb
      database_connection_user: ghostUser
      database_connection_password: gH0StSecur3
      database_connection_database: ghost
    volumes:
      - ghost-content:/var/lib/ghost/content

  wordpress:
    depends_on:
      - wpdb
    restart: always
    image: wordpress:latest
    container_name: wp
    ports:
      - 8083:80
    environment:
      WORDPRESS_DB_HOST: wpdb:3306
      WORDPRESS_DB_USER: wpUser
      WORDPRESS_DB_PASSWORD: wordPre22Secur3
      WORDPRESS_DB_NAME: wordpress

  echo:
    image: tenaciousdlg/hostresponserequest
    restart: always
    container_name: echo
    ports:
      - 8084:3000

volumes:
  ghost-data:
  wp-data:
  ghost-content:
EOF

docker-compose up -d && systemctl enable nginx && systemctl restart nginx
