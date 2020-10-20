#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# to install apache bench, required for load testing
yum -y install httpd-tools
