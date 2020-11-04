#!/bin/bash -xe

# this packer ami provisioner script should be run as ec2-user

# install packages required for test_websvr module
sudo yum -y update
sudo yum -y install git python3 python3-pip 
sudo yum -y install awscli 

# install docker compose (not currently available via amazon repos)
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# backup sysctl default values
sudo sh -c 'sysctl -a > /etc/sysctl.defaults'

# update kernel level file descriptor limit and tcp tuning parameters
sudo sed -i.original '$a\
fs.file-max = 1000000 \
net.ipv4.ip_local_port_range = 1024 65535 \
net.core.somaxconn = 8192 \
net.ipv4.tcp_tw_reuse = 1 \
net.ipv4.tcp_fin_timeout = 15 \
#net.ipv4.tcp_syncookies = 1 \
#net.ipv4.tcp_max_syn_backlog = 2048 \
#net.ipv4.tcp_synack_retries = 1 \
net.ipv4.tcp_max_tw_buckets = 1440000' /etc/sysctl.conf

# update ulimit/per process file descriptor limit
sudo sed -i.original '/# End of file/i\
* soft nofile 1000000 \
* hard nofile 1000000 \
root soft nofile 1000000 \
root hard nofile 1000000' /etc/security/limits.conf
