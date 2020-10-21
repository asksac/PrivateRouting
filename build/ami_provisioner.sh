#!/bin/bash -xe

# this packer ami provisioner script should be run as ec2-user

# install required packages for testing
sudo yum -y update
sudo yum -y install git python3 python3-pip 
sudo yum -y install awscli 

# update kernel level file descriptor limit and tcp tuning parameters
sudo sed -i.original '$a\
fs.file-max = 500000 \
net.ipv4.ip_local_port_range = 2000 65000 \
net.ipv4.tcp_tw_reuse = 1 \
net.ipv4.tcp_fin_timeout = 15 \
net.core.somaxconn = 4096' /etc/sysctl.conf

# update ulimit/per process file descriptor limit
sudo sed -i.original '/# End of file/i\
* soft nofile 500000 \
* hard nofile 500000 \
root soft nofile 500000 \
root hard nofile 500000' /etc/security/limits.conf
