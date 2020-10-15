# Running Packer Builds

## Pre-requisites

1. Install latest version of [Packer](https://www.packer.io/downloads.html) for your platform

2. Switch to the build directory (`cd build`)

3. Create a `packer.pkrvars.hcl` file with values for following required variables: 

    - `profile           = <name of aws cli profile or default>`
    - `region            = <your selected aws region, e.g. "us-east-1">`
    - `app_name          = <app/project name, e.g. "PrivateRouting">`
    - `app_shortname     = <app/project short name, e.g."prt">`
    - `proxy_image_repo  = <ecr repo name, e.g. "accountid.dkr.ecr.us-east-1.amazonaws.com/registry-name">`
    - `proxy_image_tag   = <ecr repo tag, e.g. 1.0>`

You're now ready to run the builds. 

## Build EC2 AMI

![AMI creation pipeline using Hashicorp Packer](../docs/images/packer_pipeline.png)

An AMI is required for creating WebServer, Proxy and Client EC2 instances. To create an 
AMI, run Packer from the `build` directory as follows: 

```shell
packer build -var-file=packer.pkrvars.hcl ami_build.pkr.hcl
```

## Build ECS Container Image

A Docker container image for HAProxy is required to run on ECS. Rather than use a Dockerfile, 
we use a Packer HCL script to build a Docker image, push image to an ECR registry and create a 
tag, all from a single script. To execute this step, run Packer from `build` directory as follows: 

```shell 
packer build -var-file=packer.pkrvars.hcl docker_build.pkr.hcl 
```
