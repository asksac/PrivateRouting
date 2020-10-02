variable "profile" {
  default = "terraform"
}
variable "region" {
  default = "us-east-1"
}
variable "appname" {
  default = "PrivateRouting"
}

source "amazon-ebs" "ec2_ami" {
  profile                   = "${var.profile}"
  region                    = "${var.region}"
  ami_name                  = "${var.appname}-{{timestamp}}"
  instance_type             = "c5.large"
  source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name                = "amzn2-ami-hvm-2*"
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
      "sudo yum -y install git python3 python3-pip haproxy", 
      "git clone https://github.com/asksac/PrivateRouting.git"
    ]
  }
}
