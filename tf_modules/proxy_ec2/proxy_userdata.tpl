#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

tee /root/haproxy.cfg <<EOF
global
  log stdout format raw local0 warning
  maxconn 8192
  user haproxy
  group haproxy
  master-worker

defaults
  log global
  mode tcp
  option tcplog
  option dontlognull
  option dontlog-normal
  timeout connect 5000
  timeout check 5000
  timeout client 30000
  timeout server 30000

resolvers default
  parse-resolv-conf
  #nameserver dns1 172.16.0.2:53

%{ for name, pm in port_mappings }
listen ${name} 
  bind *:${pm.proxy_port}
  server ${name}-svr ${pm.backend_host}:${pm.backend_port} check resolvers default resolve-prefer ipv4
%{ endfor }
EOF

tee /root/docker-compose.yaml <<EOF
version: "3.8"
services:
  myhaproxy:
    image: ${ecr_image_uri}
    ports:
%{ for name, pm in port_mappings }
      - "${pm.proxy_port}:${pm.proxy_port}"
%{ endfor }
    command: ["haproxy", "-db", "-d", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
    volumes: 
      - "/root/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg"
    ulimits:
      nofile:
        soft: 65535
        hard: 65535
    deploy:
      replicas: 1
    logging:
      driver: awslogs
      options:
        awslogs-region: ${aws_region}
        awslogs-group: ${log_group_name}
        awslogs-create-group: "false"
EOF

aws configure set region ${aws_region}
aws ecr get-login-password | docker login --username AWS --password-stdin ${ecr_docker_dns}
docker-compose -f /root/docker-compose.yaml up --detach
