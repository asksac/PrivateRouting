variable "profile" {}
variable "region" {
  default = "us-east-1"
}
variable "app_name" {}

source "amazon-ebs" "ec2_ami" {
  profile                   = "${var.profile}"
  region                    = "${var.region}"
  ami_name                  = "${var.app_name}-{{timestamp}}"
  instance_type             = "c5.large"
  source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name                = "amzn2-ami-ecs-hvm-2*"
        root-device-type    = "ebs"
        architecture        = "x86_64"
      }
      owners                = ["amazon"]
      most_recent           = true
  }
  communicator              = "ssh"
  ssh_username              = "ec2-user"
}

build {
  sources = [
    "source.amazon-ebs.ec2_ami"
  ]

  provisioner "shell" {
    inline                  = [
      "#!/bin/bash -xe", 
      "sudo yum -y update", 
      "sudo yum -y install git python3 python3-pip awscli", 
      "sudo amazon-linux-extras enable haproxy2", 
      "sudo yum -y install haproxy2", 
      "git clone https://github.com/asksac/PrivateRouting.git"
    ]
  }
}
