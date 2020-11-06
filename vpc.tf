# -----
# Pulls data for AZs in the region

data "aws_availability_zones" "available_azs" {}

# ------- #
## VPC 1 ##

resource "aws_vpc" "vpc1" {
  cidr_block                        = var.vpc1_cidr
  assign_generated_ipv6_cidr_block  = false
  enable_dns_support                = true
  enable_dns_hostnames              = true
  tags                              = merge(local.common_tags, map("Name", "${var.app_shortcode}_${var.vpc1_name}"))
}

resource "aws_subnet" "vpc1_subnet_priv1" {
  vpc_id                  = aws_vpc.vpc1.id
  availability_zone       = data.aws_availability_zones.available_azs.names[0]
  cidr_block              = var.vpc1_subnet_priv1_cidr
  map_public_ip_on_launch = false
  tags                    = merge(local.common_tags, map("Name", var.vpc1_subnet_priv1_name))
}

resource "aws_subnet" "vpc1_subnet_priv2" {
  vpc_id                  = aws_vpc.vpc1.id
  availability_zone       = data.aws_availability_zones.available_azs.names[1]
  cidr_block              = var.vpc1_subnet_priv2_cidr
  map_public_ip_on_launch = false
  tags                    = merge(local.common_tags, map("Name", var.vpc1_subnet_priv2_name))
}

# ------- #
## VPC 2 ##

resource "aws_vpc" "vpc2" {
  cidr_block                        = var.vpc2_cidr
  assign_generated_ipv6_cidr_block  = false
  enable_dns_support                = true
  enable_dns_hostnames              = true
  tags                              = merge(local.common_tags, map("Name", "${var.app_shortcode}_${var.vpc2_name}"))
}

resource "aws_subnet" "vpc2_subnet_priv1" {
  vpc_id                  = aws_vpc.vpc2.id
  availability_zone       = data.aws_availability_zones.available_azs.names[0]
  cidr_block              = var.vpc2_subnet_priv1_cidr
  map_public_ip_on_launch = false
  tags                    = merge(local.common_tags, map("Name", var.vpc2_subnet_priv1_name))
}

resource "aws_subnet" "vpc2_subnet_priv2" {
  vpc_id                  = aws_vpc.vpc2.id
  availability_zone       = data.aws_availability_zones.available_azs.names[1]
  cidr_block              = var.vpc2_subnet_priv2_cidr
  map_public_ip_on_launch = false
  tags                    = merge(local.common_tags, map("Name", var.vpc2_subnet_priv2_name))
}

# ------- #
## VPC 3 ##

resource "aws_vpc" "vpc3" {
  cidr_block                        = var.vpc3_cidr
  assign_generated_ipv6_cidr_block  = false
  enable_dns_support                = true
  enable_dns_hostnames              = true
  tags                              = merge(local.common_tags, map("Name", "${var.app_shortcode}_${var.vpc3_name}"))
}

resource "aws_subnet" "vpc3_subnet_pub1" {
  vpc_id                  = aws_vpc.vpc3.id
  availability_zone       = data.aws_availability_zones.available_azs.names[0]
  cidr_block              = var.vpc3_subnet_pub1_cidr
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, map("Name", var.vpc3_subnet_pub1_name))
}

resource "aws_internet_gateway" "vpc3_igw" {
  vpc_id                  = aws_vpc.vpc3.id
  tags                    = merge(local.common_tags, map("Name", "${var.app_shortcode}_${var.vpc3_name}_igw"))
}

resource "aws_route" "vpc3_igw_route" {
  route_table_id            = aws_vpc.vpc3.main_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                 = aws_internet_gateway.vpc3_igw.id
}

# ------------------- #
## VPC 2 + 3 Peering ##

resource "aws_vpc_peering_connection" "vpc2_vpc3_peering" {
  vpc_id                              = aws_vpc.vpc2.id
  peer_vpc_id                         = aws_vpc.vpc3.id
  auto_accept                         = true

  accepter {
    allow_remote_vpc_dns_resolution   = true
  }

  requester {
    allow_remote_vpc_dns_resolution   = true
  }

  tags                                = merge(local.common_tags, map("Name", "${var.vpc2_name} to ${var.vpc3_name} peering"))
}

resource "aws_route" "vpc2_vpc3_peering_route" {
  route_table_id            = aws_vpc.vpc2.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc3.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc2_vpc3_peering.id
}

resource "aws_route" "vpc3_vpc2_peering_route" {
  route_table_id            = aws_vpc.vpc3.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc2_vpc3_peering.id
}

# ------------------- #
## VPC 1 + 3 Peering ##

resource "aws_vpc_peering_connection" "vpc1_vpc3_peering" {
  vpc_id                              = aws_vpc.vpc1.id
  peer_vpc_id                         = aws_vpc.vpc3.id
  auto_accept                         = true

  accepter {
    allow_remote_vpc_dns_resolution   = true
  }

  requester {
    allow_remote_vpc_dns_resolution   = true
  }

  tags                                = merge(local.common_tags, map("Name", "${var.vpc1_name} to ${var.vpc3_name} peering"))
}

resource "aws_route" "vpc1_vpc3_peering_route" {
  route_table_id            = aws_vpc.vpc1.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc3.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc3_peering.id
}

resource "aws_route" "vpc3_vpc1_peering_route" {
  route_table_id            = aws_vpc.vpc3.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc3_peering.id
}

# ------------------- #
## VPC 1 + 2 Peering ##

resource "aws_vpc_peering_connection" "vpc1_vpc2_peering" {
  vpc_id                              = aws_vpc.vpc1.id
  peer_vpc_id                         = aws_vpc.vpc2.id
  auto_accept                         = true

  accepter {
    allow_remote_vpc_dns_resolution   = true
  }

  requester {
    allow_remote_vpc_dns_resolution   = true
  }

  tags                                = merge(local.common_tags, map("Name", "${var.vpc1_name} to ${var.vpc2_name} peering"))
}

resource "aws_route" "vpc1_vpc2_peering_route" {
  route_table_id            = aws_vpc.vpc1.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc2_peering.id
}

resource "aws_route" "vpc2_vpc1_peering_route" {
  route_table_id            = aws_vpc.vpc2.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc2_peering.id
}
