/*
variable "vpc2_subnet_pub1_cidr" {
  type    = string
  default = "172.16.2.0/24"
}

variable "vpc2_subnet_pub1_name" {
  type    = string
  default = "vpc2_pub1"
}

# -----
# Creates a public subnet and an IGW in VPC2

resource "aws_subnet" "vpc2_subnet_pub1" {
  vpc_id                  = aws_vpc.vpc2.id
  availability_zone       = data.aws_availability_zones.available_azs.names[0]
  cidr_block              = var.vpc2_subnet_pub1_cidr
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, map("Name", var.vpc2_subnet_pub1_name))
}

resource "aws_internet_gateway" "vpc2_igw" {
  vpc_id                  = aws_vpc.vpc2.id
  tags                    = merge(local.common_tags, map("Name", "${var.app_shortcode}_${var.vpc2_name}_igw"))
}

resource "aws_route" "vpc2_igw_route" {
  route_table_id            = aws_vpc.vpc2.main_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                 = aws_internet_gateway.vpc2_igw.id
}

# -----
# Configures NATGW with EIP in VPC2 - Routes VPC2 Internet bound traffic through NATGW

resource "aws_eip" "eip_for_natgw" {
  vpc           = true
}

resource "aws_nat_gateway" "natgw" {
  allocation_id   = aws_eip.eip_for_natgw.id
  subnet_id       = aws_subnet.vpc2_subnet_pub1.id
  tags            = merge(local.common_tags, map("Name", "${var.app_shortcode}_${var.vpc2_name}_natgw"))
}

resource "aws_route_table" "nat_route_tab" {
  vpc_id = aws_vpc.vpc2.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
  route {
    cidr_block = aws_vpc.vpc3.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc2_vpc3_peering.id
  }   
}

resource "aws_route_table_association" "nat_route_assoc_1" { 
  subnet_id = aws_subnet.vpc2_subnet_priv1.id
  route_table_id = aws_route_table.nat_route_tab.id
}

resource "aws_route_table_association" "nat_route_assoc_2" { 
  subnet_id = aws_subnet.vpc2_subnet_priv2.id
  route_table_id = aws_route_table.nat_route_tab.id
}
*/