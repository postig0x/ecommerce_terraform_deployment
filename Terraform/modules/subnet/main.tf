# public subnet setup + internet gateway + route table
#
#
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "wl5_igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# private subnet setup + nat gateway + route table
#
#
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# vpc peering
#
#
# default vpc data
data "aws_vpc" "default" {
  default = true
}

# default route table data
data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_vpc_peering_connection" "wl5peer" {
  peer_vpc_id = var.vpc_id
  vpc_id      = data.aws_vpc.default.id
  auto_accept = true
}

# add vpc peering route to default route table
resource "aws_route" "vpc_peering" {
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.wl5peer.id
}

resource "aws_route" "public_to_default" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.wl5peer.id
}

# public outputs
#
#
output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

# private outputs
#
#
output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT gateways"
  value       = aws_nat_gateway.ngw[*].id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = aws_route_table.private[*].id
}
