data "template_file" "websvr_user_data_script" {
  template = <<EOF
#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo -b -u ec2-user python3 /home/ec2-user/PrivateRouting/src/webapp/server.py ${var.websvr_listen_port} &
EOF
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
    from_port     = var.websvr_listen_port
    to_port       = var.websvr_listen_port
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
  source_dest_check       = false

  depends_on              = [aws_internet_gateway.vpc3_igw]

  tags                    = merge(local.common_tags, map("Name", "${var.app_shortcode}_websvr"))
}

output "websvr_arn" {
  value = aws_instance.websvr.arn
}

output "websvr_base_url" {
  value = "http://${aws_instance.websvr.public_dns}:${var.websvr_listen_port}/"
}