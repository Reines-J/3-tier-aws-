resource "aws_vpc" "vpc" {
  cidr_block       = "10.${var.cidr}.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "pub" {
  count = length(var.az)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.${var.cidr}.${var.cidr_public[count.index]}.0/24"
  availability_zone = element(var.az, count.index)

  tags = {
    Name = format("%s-%s", var.tag, "PUB${count.index+1}" )
  }
}

resource "aws_subnet" "pric" {
  count = length(var.cidr_privatec)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.${var.cidr}.${var.cidr_privatec[count.index]}.0/24"
  availability_zone = "${var.az[0]}"

  tags = {
    Name = format("%s-%s", var.tag, "PRIC${count.index+1}" )
  }
}

resource "aws_subnet" "prid" {
  count = length(var.cidr_privated)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.${var.cidr}.${var.cidr_privated[count.index]}.0/24"
  availability_zone = "${var.az[1]}"

  tags = {
    Name = format("%s-%s", var.tag, "PRID${count.index+1}" )
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s-%s", var.tag, "IGW" )
  }
}

resource "aws_eip" "nat"{
  count = length(var.az)
  vpc   = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "ngw"{
  count = length(var.az)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id = element(aws_subnet.pub.*.id, count.index)
  tags = {
    Name = format("%s-%s", var.tag, "NGW${count.index+1}" )
  }
}

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = format("%s-%s", var.tag, "PUBROUTE" )
  }
}

resource "aws_route_table" "pri" {
  count = length(var.az)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = format("%s-%s", var.tag, "PRIROUTE${count.index+1}" )
  }
}

resource "aws_route_table_association" "pub" {
  count = length(aws_subnet.pub.*.id)
  subnet_id = element(aws_subnet.pub.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pric" {
  count = length(aws_subnet.pric.*.id)
  subnet_id = element(aws_subnet.pric.*.id, count.index)
  route_table_id = aws_route_table.pri[0].id
}

resource "aws_route_table_association" "prid" {
  count = length(aws_subnet.prid.*.id)
  subnet_id = element(aws_subnet.prid.*.id, count.index)
  route_table_id = aws_route_table.pri[1].id
}

resource "aws_route" "pub" {
  route_table_id = aws_route_table.pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "pri"{
  count = length(var.az)
  route_table_id = element(aws_route_table.pri.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
}

resource "aws_security_group" "threesg" {
  count = length(var.sg)
  vpc_id = aws_vpc.vpc.id
  name = "3tier-sg${count.index+1}"
  description = "3tier-sg${count.index+1}"
  tags = {
    Name = format("%s-%s", var.tag, "treetier${count.index+1}" )
  }
}

resource "aws_security_group_rule" "httpexelb" {
  type = "ingress"
  from_port =  80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.threesg[0].id
}

resource "aws_security_group_rule" "httpweb" {
  type = "ingress"
  from_port =  80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.threesg[1].id
}

resource "aws_security_group_rule" "httpinelb" {
  type = "ingress"
  from_port =  8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = aws_security_group.threesg[1].id
  security_group_id = aws_security_group.threesg[2].id
}

resource "aws_security_group_rule" "httpwas" {
  type = "ingress"
  from_port =  8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = aws_security_group.threesg[2].id
  security_group_id = aws_security_group.threesg[3].id
}

resource "aws_security_group_rule" "mysql" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = aws_security_group.threesg[3].id
  security_group_id = aws_security_group.threesg[4].id
}


resource "aws_security_group_rule" "outboundall" {
  count = length(var.sg)
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = element(aws_security_group.threesg.*.id, count.index)
}