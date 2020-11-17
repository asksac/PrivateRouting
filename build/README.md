# Running Packer Builds

## Prerequisite Steps

1. Install latest version of [Packer](https://www.packer.io/downloads.html) for your platform

2. Switch to build directory (`cd build`)

3. Create a `packer.pkrvars.hcl` file with your own values of following required variables: 

    - `profile           = <name of aws cli profile e.g. "terraform">`
    - `region            = <your selected aws region, e.g. "us-east-2">`
    - `app_name          = <app/project name, e.g. "ProxyRouting">`
    - `app_shortname     = <app/project short name, e.g."prt">`
    - `proxy_image_repo  = <ecr repo name, e.g. "accountid.dkr.ecr.us-east-1.amazonaws.com/haproxy-registry">`
    - `proxy_image_tag   = <ecr repo tag, e.g. "latest">`

> :information_source: Value specified for `proxy_image_repo` must correspond to the output 
value from running _Step 3. Create an ECR repository_ on the main [README page](../README.md). 
Value specified for `proxy_image_tag` variable must match that of `ecr_proxy_image_tag` 
value in `terraform.tfvars` file created in the root module. 

You're now ready to run the builds. 

## Build EC2 AMI

![AMI creation pipeline using Hashicorp Packer](../docs/images/packer_pipeline.png)

A customized AMI is required for creating WebServer, Proxy and Client EC2 instances. To 
create the AMI, run Packer from `build` directory as follows: 

```shell
packer build -var-file=packer.pkrvars.hcl ami_build.pkr.hcl
```

This step may take several minutes to execute. At the end, you'll have a new AMI created in 
your AWS account. 

> :information_source: You may edit and update `ami_provisioner.sh` file to customize the 
AMI to suit your project needs. This could include installing other software components 
(such as CloudWatch agent) or fine-tuning `sysctl` parameters. 


## Build ECS Container Image

A Docker container image with HAProxy is required to run the proxy on ECS and EC2. Instead 
of using a Dockerfile, we use a Packer HCL script to build the Docker image, push to an ECR 
registry and create a tag, all in a single script. This step requires Docker daemon to be up
and running on the build workstation or server, as well as access to Internet to pull the 
source HAProxy image. 

To execute this step, run Packer from `build` directory as follows: 

```shell 
packer build -var-file=packer.pkrvars.hcl docker_build.pkr.hcl 
```

At the end of this step, you will have a new Docker container image created, pushed and 
tagged into the specified ECR repository. 