# Private Network Routing from AWS to On-Premise

## Overview

This project offers an example of how network connections can be securely
routed from an AWS VPC to an external network that uses public IP address
space via a Virtual Private Gateway or VPC peering. 

## Diagram

![AWS VPC network diagram](docs/images/aws_vpc_diagram.png)

## Deployment

### 1. Build the AMI and ECS Container Image

Refer to [this page](build/README.md) for instructions on building AMI and Docker container image. 

## Troubleshooting

### Useful commands

- Login to ECR: `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin accountid.dkr.ecr.us-east-1.amazonaws.com`
- Pull container image: `docker pull accountid.dkr.ecr.us-east-1.amazonaws.com/prt-registry:1.0`
- List docker images: `docker images`
- Start a docker container: `docker run -d --rm --ulimit nofile=10000:10000 -p 88:8888 accountid.dkr.ecr.us-east-1.amazonaws.com/prt-registry:1.0`
- List running containers: `docker container ps`
- SSH into a container: `docker exec -it <container_id> /bin/sh`

### Important links

- Refresh DNS cache and retrying backend: https://serverfault.com/questions/666600/haproxy-does-not-recover-after-failed-check 


## Notes

The version of `haproxy` found in Amazon Linux 2 core repo is a bit outdated, as seen in output below: 

```shell
$ yum info haproxy
Loaded plugins: priorities, update-motd, upgrade-helper
Available Packages
Name        : haproxy
Arch        : x86_64
Version     : 1.5.18
Release     : 9.amzn2
Size        : 831 k
Repo        : amzn2-core/2/x86_64
Summary     : TCP/HTTP proxy and load balancer for high availability environments
URL         : http://www.haproxy.org/
License     : GPLv2+
...
```

However, a newer version of `haproxy` can be found in `amazon-extras` repo, as seen below: 

```shell
$ sudo amazon-linux-extras enable haproxy2
  0  ansible2                 available    \
 ... 
 45  haproxy2=latest          enabled      [ =stable ]
 ...

$ yum info haproxy2
Loaded plugins: priorities, update-motd, upgrade-helper
Installed Packages
Name        : haproxy2
Arch        : x86_64
Version     : 2.1.4
Release     : 1.amzn2.0.1
Size        : 5.2 M
Repo        : installed
From repo   : amzn2extra-haproxy2
Summary     : HAProxy reverse proxy for high availability environments
URL         : http://www.haproxy.org/
License     : GPLv2+
...
```

To generate a self-signed SSL certificate required to run `server.py` with `--tls` flag, run the 
following command: 

```shell
openssl req -x509 -nodes -newkey rsa:1024 -keyout config/ssl/key.pem -out config/ssl/cert.pem \
  -days 1825 -subj "/C=US/ST=IL/L=Chicago/O=Amazon.com, Inc./OU=Amazon Web Services/CN=aws.amazon.com"
```

*As this is for testing purposes only, we are generating the private key file with no password (-nodes), 
using a longer duration (-days 1825) and using dummy certificate details (-subj)*

## Changelog

Updates on 2020-10-15:
- Separate terraform modules, one each for:
  - HAProxy on ECS Fargate cluster
  - HAProxy on EC2 (helpful for testing)
- Support for multiple subnets 
- Using PrivateLink (VPC endpoints) for ECR, S3 and CloudWatch Logs
- Eliminated need for NATGW in HAProxy VPC

Updates on 2020-10-14:
- Support for an input map object to configure HAProxy rules
- Refactor code into terraform modules 


## License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
- Copyright 2020 &copy; Sachin Hamirwasia
