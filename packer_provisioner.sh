#!/bin/bash -xe
sudo yum -y install git python3 python3-pip jq
sudo yum -y install haproxy

# download source files from github
git clone https://github.com/asksac/PrivateRouting.git

# get region from instance metadata
REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r`
aws configure set region $REGION
