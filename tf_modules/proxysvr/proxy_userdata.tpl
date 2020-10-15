#!/bin/bash -xe

# this is an ec2 user data script that creates an haproxy.cfg file
# and restarts haproxy2 service (haproxy2 package must be installed)

mv /etc/haproxy2/haproxy2.cfg /etc/haproxy2/haproxy2.cfg.original
tee /etc/haproxy2/haproxy2.cfg <<EOF
global
  log stdout format raw daemon
  maxconn 4096
  user haproxy
  group haproxy
  daemon
  master-worker

defaults
  log global
  mode tcp
  timeout connect 60s
  timeout client 600s
  timeout server 1h

%{ for name, pm in port_mappings }
listen ${name}_fe: 
  bind *:${pm.proxy_port}
  server ${name}_be ${pm.backend_host}:${pm.backend_port}
%{ endfor }

EOF
systemctl restart haproxy2
