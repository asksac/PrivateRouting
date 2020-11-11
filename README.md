# Private Network Routing from AWS to On-Premise

## Overview

This repo offers an example of how network connections can be securely routed from an AWS 
VPC to a backend network (such as an on-premise network) using a TCP proxy. This may be 
needed in scenarios such as when the backend network uses public IP address space, or 
when destination network address translation (DNAT) is required. AWS offers a managed NAT
Gateway, but it only supports source network address translation (SNAT) and requires an 
Internet Gateway (in some cases, Internet Gateways are prohibited for security reasons).

TCP proxy is implemented using the popular open-source [HAProxy](http://www.haproxy.org/) 
load balancer. HAProxy is used as a lightweight and high-performance L4 TCP proxy which 
supports DNS based backend hostnames. 

This repo uses Terraform to deploy the proxy infrastructure on AWS. It uses Packer to 
create a custom EC2 AMI, and to build and deploy a Docker container image for HAProxy. 
Refer to [Deployment](#Deployment) section for more details. 


## Modules 

This repo offers several Terraform modules to assist in deployment and testing. These are: 
| Module name | Doc page | Used to |
| --- | --- | --- |
| proxy_ecs | [README](tf_modules/proxy_ecs/README.md) | deploy HAProxy on an ECS Fargate cluster |
| proxy_ec2 | [README](tf_modules/proxy_ec2/README.md) | deploy HAProxy on an EC2 cluster |
| proxy_endpoint | [README](tf_modules/proxy_endpoint/README.md) | create a VPC endpoint to an HAProxy cluster |
| test_websvr | [README](tf_modules/test_websvr/README.md) | create a WebServer instance for testing |
| test_client | [README](tf_modules/test_client/README.md) | create a client instance for testing |
| _root_ | [README](TFROOT.md) | setup a demo environment using all modules |


## Diagram

HAProxy can be deployed using either `ECS on Fargate cluster` or `EC2 Auto Scaling cluster` 
depending on preference and project complexity. The diagrams below shows a reference networking 
and infrastructure setup for deployment scenarios. 

| HAProxy on ECS Fargate cluster | HAProxy on EC2 cluster |
| :---: | :---: |
| [Figure 1](docs/images/diagram_haproxy_ecs_fargate.png) | [Figure 2](docs/images/diagram_haproxy_ec2.png) |
| <img src="docs/images/diagram_haproxy_ecs_fargate.png" width="500"/> | <img src="docs/images/diagram_haproxy_ec2.png" width="500"> |
| [Module: proxy_ecs](tf_modules/proxy_ecs/) | [Module: proxy_ec2](tf_modules/proxy_ec2/) |


## Deployment

### Building AMI and ECS Container Image

Refer to [this page](build/README.md) for instructions on building AMI and 
Docker container image. 

## Troubleshooting

### Useful commands

- Login to ECR: `aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <accountid>.dkr.ecr.<region>.amazonaws.com`
- Pull container image: `docker pull <accountid>.dkr.ecr.us-east-1.amazonaws.com/prt-registry:1.0`
- List docker images: `docker images`
- Start a docker container: `docker run -d --rm --ulimit nofile=10000:10000 -p 88:8888 <accountid>.dkr.ecr.us-east-1.amazonaws.com/prt-registry:1.0`
- List running containers: `docker container ps`
- SSH into a container: `docker exec -it <container_id> /bin/sh`
- Set SSM Parameter: `export HAPROXY_CONFIG=$(aws ssm get-parameters --name /PrivateRouting/HAPROXY_CONFIG --region us-east-1 --query Parameters[0].Value --output text)`

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

> :bell: Note: The HAProxy Docker container image used in this project is based on the image published on ![Docker Hub](https://hub.docker.com/_/haproxy). If you do not have Internet access, you will need to pull the Docker Hub image from a machine with Internet access and then push the image to a private registry such as Amazon ECR. 

To generate a self-signed SSL certificate required to run `server.py` with `--tls` flag, run the 
following command: 

```shell
openssl req -x509 -nodes -newkey rsa:1024 -keyout config/ssl/key.pem -out config/ssl/cert.pem \
  -days 1825 -subj "/C=US/ST=IL/L=Chicago/O=Amazon.com, Inc./OU=Amazon Web Services/CN=aws.amazon.com"
```

*As this is for testing purposes only, we are generating the private key file with no password (-nodes), 
using a longer duration (-days 1825) and using dummy certificate details (-subj)*


## License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
- Copyright 2020 &copy; Sachin Hamirwasia
