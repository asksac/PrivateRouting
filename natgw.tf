/*
# -----
# Configures NATGW with EIP in VPC #2 - Route VPC #3 destined IPs through NATGW

resource "aws_eip" "eip_for_natgw1" {
  vpc           = true
}

resource "aws_nat_gateway" "natgw1" {
  allocation_id   = aws_eip.eip_for_natgw1.id
  subnet_id       = aws_subnet.vpc2_subnet_priv1.id
  tags            = local.common_tags
}

resource "aws_route_table" "nat_route_tab_1" {
  vpc_id = aws_vpc.vpc2.id
  route {
       cidr_block = var.vpc3_cidr
       gateway_id = aws_nat_gateway.natgw1.id
   }
}

resource "aws_route_table_association" "nat_route_assoc_1" { 
  subnet_id = aws_subnet.db_subnet_1.id
  route_table_id = aws_route_table.nat_route_tab_1.id
}

# -----
# Updates the existing default route table 

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main_vpc.default_route_table_id
  route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.main_igw.id
   }
}
*/