resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.common_tags
}

resource "aws_subnet" "front" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.vpc_front_subnets)
  cidr_block              = var.vpc_front_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index]
  tags                    = merge({ "Name" : "${var.project_name}-front" }, var.common_tags)
}

resource "aws_subnet" "app" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.vpc_app_subnets)
  cidr_block              = var.vpc_app_subnets[count.index]
  map_public_ip_on_launch = false
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index]
  tags                    = merge({ "Name" : "${var.project_name}-app" }, var.common_tags)
}

resource "aws_subnet" "db" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.vpc_db_subnets)
  cidr_block              = var.vpc_db_subnets[count.index]
  map_public_ip_on_launch = false
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index]
  tags                    = merge({ "Name" : "${var.project_name}-db" }, var.common_tags)
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.common_tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ "Name" : "${var.project_name}-public" }, var.common_tags)
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.vpc_front_subnets)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.front.*.id[count.index]
}

resource "aws_eip" "nat" {
  count = length(var.vpc_front_subnets)
  vpc   = true
}

resource "aws_nat_gateway" "gw" {
  count         = length(var.vpc_front_subnets)
  allocation_id = aws_eip.nat.*.id[count.index]
  subnet_id     = aws_subnet.front.*.id[count.index]
}

resource "aws_route_table" "private" {
  count  = length(var.vpc_front_subnets)
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ "Name" : "${var.project_name}-private" }, var.common_tags)
}


resource "aws_route" "private" {
  count                  = length(var.vpc_front_subnets)
  route_table_id         = aws_route_table.private.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw.*.id[count.index]
}

resource "aws_route_table_association" "private_app" {
  count          = length(var.vpc_app_subnets)
  route_table_id = aws_route_table.private.*.id[count.index]
  subnet_id      = aws_subnet.app.*.id[count.index]
}

resource "aws_route_table_association" "private_db" {
  count          = length(var.vpc_db_subnets)
  route_table_id = aws_route_table.private.*.id[count.index]
  subnet_id      = aws_subnet.db.*.id[count.index]
}
