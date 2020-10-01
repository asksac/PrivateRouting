# -----
# Configures NATGW with EIP in VPC#3 - Route VPC#2 Internet bound traffic through NATGW

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
       gateway_id = aws_nat_gateway.natgw.id
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

/*
resource "aws_default_route_table" "natgw_route" {
  default_route_table_id  = aws_vpc.vpc2.default_route_table_id
  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_nat_gateway.natgw.id
   }
}
*/