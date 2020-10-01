/*
# using standard Amazon Linux 2
data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name      = "name"
    values    = ["amzn2-ami-hvm-2*"]
  }

  filter {
    name      = "architecture"
    values    = ["x86_64"]
  }

  filter {
    name      = "root-device-type"
    values    = ["ebs"]
  }

  filter {
    name      = "virtualization-type"
    values    = ["hvm"]
  }
}
*/

# using custom ami created using packer
data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name      = "name"
    values    = ["${var.app_name}-*"]
  }

}

output "ec2_ami_arn" {
  value = data.aws_ami.ec2_ami.arn
}