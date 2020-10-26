#!/bin/bash -xe

# this packer ami provisioner script should be run as ec2-user

# install required packages for testing
sudo yum -y update
sudo yum -y install git python3 python3-pip 
sudo yum -y install awscli 

# update kernel level file descriptor limit and tcp tuning parameters
sudo sed -i.original '$a\
fs.file-max = 1000000 \
net.ipv4.ip_local_port_range = 1024 65535 \
net.ipv4.tcp_tw_reuse = 1 \
net.ipv4.tcp_fin_timeout = 15 \
net.core.somaxconn = 4096 \
net.ipv4.tcp_max_tw_buckets = 1440000' /etc/sysctl.conf

# update ulimit/per process file descriptor limit
sudo sed -i.original '/# End of file/i\
* soft nofile 1000000 \
* hard nofile 1000000 \
root soft nofile 1000000 \
root hard nofile 1000000' /etc/security/limits.conf
