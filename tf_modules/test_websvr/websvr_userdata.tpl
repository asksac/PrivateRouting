#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# this is an ec2 user data script that sets up a simple echo webserver (server.py)
# listening on http/https ports, and a more robust nginx based webserver

# download our application code from github
su ec2-user -c 'git clone https://github.com/asksac/PrivateRouting.git /home/ec2-user/PrivateRouting'

# nginx installation - for webserver
amazon-linux-extras enable nginx1
yum install -y nginx
nginx -v

mkdir -p /var/www/html/
echo 'This is index.html!' > /var/www/html/index.html
base64 -w 0 /dev/urandom | head -c 1024 > /var/www/html/1k.txt
base64 -w 0 /dev/urandom | head -c 10240 > /var/www/html/10k.txt
base64 -w 0 /dev/urandom | head -c 1048576 > /var/www/html/1m.txt
chown -R ec2-user:ec2-user /var/www/html/

mkdir /var/log/PrivateRouting
chown ec2-user:ec2-user /var/log/PrivateRouting

export PR_HOME=/home/ec2-user/PrivateRouting
%{ for port in websvr_listen_ports.server_http_ports ~}
python3 $PR_HOME/src/webapp/server.py ${port} &
%{ endfor ~}

%{ for port in websvr_listen_ports.server_https_ports ~}
python3 $PR_HOME/src/webapp/server.py ${port} --tls --keyfile $PR_HOME/config/ssl/key.pem --certfile $PR_HOME/config/ssl/cert.pem &
%{ endfor ~}

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original
tee /etc/nginx/nginx.conf <<EOF
user nginx; ## Default: nobody
worker_processes  auto;  ## Default: 1
worker_rlimit_nofile 500000; 
pid /run/nginx.pid;

error_log  /var/log/nginx/error.log crit;

events {
  worker_connections  4096;  ## Default: 1024
  multi_accept on; 
}

http {
  server {
%{ for port in websvr_listen_ports.nginx_http_ports ~}
    listen              ${port};
%{ endfor ~}
%{ for port in websvr_listen_ports.nginx_https_ports ~}
    listen              ${port} ssl;
%{ endfor ~}
    server_name         _;

    ssl_certificate     /home/ec2-user/PrivateRouting/config/ssl/cert.pem;
    ssl_certificate_key /home/ec2-user/PrivateRouting/config/ssl/key.pem;

    access_log off; # /var/log/nginx/access.log;

    tcp_nopush on; 
    tcp_nodelay on; 

    reset_timedout_connection on; 
    client_body_timeout 10; 
    send_timeout 2; 
    keepalive_timeout 30;
    keepalive_requests 100000;

    root /var/www/html/;
    index index.html index.htm index.php;
  }
}
EOF
systemctl restart nginx
systemctl status nginx

yum install -y httpd

mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.original
tee /etc/httpd/conf/httpd.conf <<EOF
ServerRoot "/etc/httpd"
Listen 8080
Include conf.modules.d/*.conf

User apache
Group apache
ServerAdmin root@localhost

<Directory />
    AllowOverride none
    Require all denied
</Directory>

DocumentRoot "/var/www/html"

<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>

<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>

<Files ".ht*">
    Require all denied
</Files>

ErrorLog "logs/error_log"
LogLevel warn

<IfModule mod_http2.c>
    Protocols h2 h2c http/1.1
</IfModule>
EOF
