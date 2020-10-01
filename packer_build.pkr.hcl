variable "profile" {}
variable "region" {
  default = "us-east-1"
}
variable "appname" {}

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
      script                = "packer_provisioner.sh"
  }
}
