data "aws_subnet_ids" "pub"{
  vpc_id = aws_vpc.vpc.id
  filter {
    name = "subnet-id"
    values = aws_subnet.pub.*.id
  }
}

data "aws_subnet_ids" "pri"{
    count = length(var.cidr_privatec)
    vpc_id  = aws_vpc.vpc.id
    filter {
      name = "cidr-block"
      values = [
        "10.${var.cidr}.${var.cidr_privatec[count.index]}.0/24",
        "10.${var.cidr}.${var.cidr_privated[count.index]}.0/24"
      ]
    }
}

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

