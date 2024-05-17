resource "aws_vpc" "cmc_vpc" {
  cidr_block = var.vpc_id
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.project_name}-VPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "cmc_public_subnet_1a" {
  vpc_id = aws_vpc.cmc_vpc.id
  cidr_block = var.public_subnet_1a
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
        Name = "${var.project_name}-public-subnet-us-east-1a"
        "kubernetes.io/cluster/eks" = "shared"
        "kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "cmc_public_subnet_1b" {
  vpc_id = aws_vpc.cmc_vpc.id
  cidr_block = var.public_subnet_1b
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
        Name = "${var.project_name}-public-subnet-us-east-1b"
        "kubernetes.io/cluster/eks" = "shared"
        "kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "cmc_private_subnet_1a" {
  vpc_id = aws_vpc.cmc_vpc.id
  cidr_block = var.private_subnet_1a
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
        Name = "${var.project_name}-private-subnet-us-east-1a"
        "kubernetes.io/cluster/eks" = "shared"
        "kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "cmc_private_subnet_1b" {
  vpc_id = aws_vpc.cmc_vpc.id
  cidr_block = var.private_subnet_1b
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
        Name = "${var.project_name}-private-subnet-us-east-1b"
        "kubernetes.io/cluster/eks" = "shared"
        "kubernetes.io/role/elb" = 1
    }
}

resource "aws_internet_gateway" "cmc_igw" {
  vpc_id = aws_vpc.cmc_vpc.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "cmc_route_public" {
  vpc_id = aws_vpc.cmc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cmc_igw.id
  }
  tags = {
    Name = "${var.project_name}-public-rtb"
  }
}

resource "aws_route_table" "cmc_route_private_rtb" {
  vpc_id = aws_vpc.cmc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.cmc_nat_gw.id
  }
  tags = {
    Name = "${var.project_name}-private-rtb"
  }
}

resource "aws_eip" "cmc_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "cmc_nat_gw" {
    subnet_id = aws_subnet.cmc_public_subnet_1a.id
  allocation_id = aws_eip.cmc_eip.id
  tags = {
    Name = "${var.project_name}-natgw"
  }
  depends_on = [aws_internet_gateway.cmc_igw]
}

resource "aws_route_table_association" "cmc_rtb_ass_public_1a" {
  route_table_id = aws_route_table.cmc_route_public.id
  subnet_id = aws_subnet.cmc_public_subnet_1a.id
}
resource "aws_route_table_association" "cmc_rtb_ass_public_1b" {
  route_table_id = aws_route_table.cmc_route_public.id
  subnet_id = aws_subnet.cmc_public_subnet_1b.id
}

resource "aws_route_table_association" "cmc_rtb_ass_private_1a" {
  route_table_id = aws_route_table.cmc_route_private_rtb.id
  subnet_id = aws_subnet.cmc_private_subnet_1a.id
}

resource "aws_route_table_association" "cmc_rtb_ass_private_1b" {
  route_table_id = aws_route_table.cmc_route_private_rtb.id
  subnet_id = aws_subnet.cmc_private_subnet_1b.id
}

