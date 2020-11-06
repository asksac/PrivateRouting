#
# Defines data source for our custom ami created using packer 
# Refer: build/ami_build.pkr.hcl
#
data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name      = "name"
    values    = ["${var.app_name}-*"]
  }
}
