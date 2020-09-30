data "template_file" "proxy_user_data_script" {
  template = <<EOF
#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

yum -y install git python3 python3-pip 
yum -y install haproxy
EOF
}

resource "aws_security_group" "proxy_sg" {
  name            = "proxy_sg"
  vpc_id          = aws_vpc.vpc2.id
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

resource "aws_instance" "proxy" {
  ami                     = data.aws_ami.ec2_ami.id
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.vpc2_subnet_priv1.id
  vpc_security_group_ids  = [aws_security_group.proxy_sg.id]
  key_name                = var.ec2_ssh_keypair_name
  user_data               = data.template_file.proxy_user_data_script.template

  tags                    = merge(local.common_tags, map("Name", "${var.app_shortcode}_proxy"))
}

output "proxy_dns" {
  value = aws_instance.proxy.private_dns
}
