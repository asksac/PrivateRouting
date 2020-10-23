#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# this is an ec2 user data script that creates an haproxy.cfg file
# and restarts haproxy2 service (haproxy2 package must be installed)

# install haproxy v2.1.4 from amazon extras repo
amazon-linux-extras enable haproxy2
yum -y install haproxy2 
haproxy2 -v

yum install -y rsyslog
tee /etc/rsyslog.d/haproxy.conf <<EOF
# Collect log with UDP
\$ModLoad imudp
\$UDPServerAddress 127.0.0.1
\$UDPServerRun 514

# Creating separate log files based on the severity
local0.* /var/log/haproxy-traffic.log
local0.notice /var/log/haproxy-admin.log
EOF
systemctl restart rsyslog
systemctl status rsyslog

mv /etc/haproxy2/haproxy2.cfg /etc/haproxy2/haproxy2.cfg.original
tee /etc/haproxy2/haproxy2.cfg <<EOF
global
  log 127.0.0.1:514 local0 info
  maxconn 8192
  maxpipes 16384
  ulimit-n 1000000
  user haproxy
  group haproxy
  daemon
  master-worker

defaults
  log global
  mode tcp
  option tcplog
  option dontlognull
  timeout connect 5000
  timeout check 5000
  timeout client 30000
  timeout server 30000

%{ for name, pm in port_mappings }
listen ${name}: 
  bind *:${pm.proxy_port}
  server ${name}-svr ${pm.backend_host}:${pm.backend_port} check
%{ endfor }

EOF
systemctl restart haproxy2
systemctl status haproxy2
