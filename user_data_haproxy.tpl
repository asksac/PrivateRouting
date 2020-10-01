#!/bin/bash -xe
mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.original
tee /etc/haproxy/haproxy.cfg <<EOF
global
  daemon
  maxconn 4096
  user haproxy
  group haproxy

defaults
  log global
  mode http
  timeout connect 300s
  timeout client 600s
  timeout server 1h
  option httpchk

frontend www
  mode http
  bind *:${proxy_listen_http_port}
  default_backend websvr_be

backend websvr_be
  mode http
  server websvr_http ${websvr_dns}:${websvr_listen_port} 

frontend ssh_fe
  mode tcp
  bind *:${proxy_listen_ssh_port}
  default_backend ssh_be
  timeout client 1h

backend ssh_be
  mode tcp
  server websvr_ssh ${websvr_dns}:22 
EOF
service haproxy restart
