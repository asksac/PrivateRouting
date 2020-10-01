data "template_file" "proxy_user_data_script" {
  template = file("user_data_haproxy.tpl")
  vars = {
    proxy_listen_port = var.proxy_listen_port
    websvr_dns = aws_instance.websvr.public_dns
    websvr_listen_port = var.websvr_listen_port
  }
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
    from_port     = var.proxy_listen_port
    to_port       = var.proxy_listen_port
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
  user_data               = data.template_file.proxy_user_data_script.rendered
  source_dest_check       = false

  tags                    = merge(local.common_tags, map("Name", "${var.app_shortcode}_proxy"))
}

output "proxy_dns" {
  value = aws_instance.proxy.private_dns
}
