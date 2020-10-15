resource "aws_security_group" "client_sg" {
  name            = "client_sg"
  vpc_id          = aws_vpc.vpc1.id
  ingress {
    cidr_blocks   = ["0.0.0.0/0"]
    from_port     = 22
    to_port       = 22
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

resource "aws_instance" "client_ec2" {
  ami                     = data.aws_ami.ec2_ami.id
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.vpc1_subnet_priv1.id
  vpc_security_group_ids  = [aws_security_group.client_sg.id]
  key_name                = var.ec2_ssh_keypair_name
  source_dest_check       = true

  tags                    = merge(local.common_tags, map("Name", "${var.app_shortcode}_client"))
}
