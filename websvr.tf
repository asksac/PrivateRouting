data "template_file" "websvr_user_data_script" {
  template = <<EOF
#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo mkdir /var/log/PrivateRouting
sudo chown ec2-user:ec2-user /var/log/PrivateRouting

PR_HOME=/home/ec2-user/PrivateRouting
sudo -b -u ec2-user python3 $PR_HOME/src/webapp/server.py ${var.websvr_listen_http_port} &
sudo -b -u ec2-user python3 $PR_HOME/src/webapp/server.py ${var.websvr_listen_https_port} --tls --keyfile $PR_HOME/config/ssl/key.pem --certfile $PR_HOME/config/ssl/cert.pem &
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
    cidr_blocks   = [var.vpc2_cidr]
    from_port     = var.websvr_listen_http_port
    to_port       = var.websvr_listen_http_port
    protocol      = "tcp"
  }
  ingress {
    cidr_blocks   = [var.vpc2_cidr]
    from_port     = var.websvr_listen_https_port
    to_port       = var.websvr_listen_https_port
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
  instance_type           = "c5.large"
  subnet_id               = aws_subnet.vpc3_subnet_pub1.id
  vpc_security_group_ids  = [aws_security_group.websvr_sg.id]
  key_name                = var.ec2_ssh_keypair_name
  user_data               = data.template_file.websvr_user_data_script.template
  source_dest_check       = false

  depends_on              = [aws_internet_gateway.vpc3_igw]

  tags                    = merge(local.common_tags, map("Name", "${var.app_shortcode}_websvr"))
}
