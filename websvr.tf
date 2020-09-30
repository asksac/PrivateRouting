data "template_file" "websvr_user_data_script" {
  template = <<EOF
#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

yum -y install git python3 python3-pip

# download source files from github
git clone https://github.com/asksac/PrivateRouting.git
cd PrivateRouting

python3 ./src/webapp/server.py 8080
EOF
}

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

resource "aws_security_group" "websvr_sg" {
  name            = "websvr_sg"
  vpc_id          = aws_vpc.vpc3.id
  ingress {
    cidr_blocks   = ["0.0.0.0/0"]
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
  }
  ingress {
    cidr_blocks   = ["0.0.0.0/0"]
    from_port     = 8080
    to_port       = 8080
    protocol      = "tcp"
  }
  # Terraform removes the default rule
  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "websvr" {
  ami                     = data.aws_ami.ec2_ami.id
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.vpc3_subnet_pub1.id
  vpc_security_group_ids  = [aws_security_group.websvr_sg.id]
  key_name                = var.ec2_ssh_keypair_name
  user_data               = data.template_file.websvr_user_data_script.template

  depends_on              = [aws_internet_gateway.vpc3_igw]

  tags                    = merge(local.common_tags, map("Name", "${var.app_shortcode}_websvr"))
}

output "websvr_arn" {
  value = aws_instance.websvr.arn
}

output "websvr_base_url" {
  value = "http://${aws_instance.websvr.public_dns}:8080/"
}