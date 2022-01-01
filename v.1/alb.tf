
resource "aws_lb" "l7web" {
  name = "${var.tag}-l7web"
  internal = false
  load_balancer_type = "application"
  ip_address_type = "ipv4"
  security_groups = [aws_security_group.threesg[0].id]
  subnets = data.aws_subnet_ids.pub.ids
  tags = { Name = "${var.tag}-l7web"}
}

resource "aws_lb_target_group" "l7groupweb" {
  name = "${var.tag}-l7groupweb"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.vpc.id
  health_check {
    protocol = "HTTP"
    path = "/"
  }
  tags = {NAME = "${var.tag}-l7groupweb"}
}

resource "aws_lb_listener" "l7listenweb" {
  load_balancer_arn = aws_lb.l7web.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.l7groupweb.arn
  }
  tags = {NAME = "${var.tag}-l7listenweb"}
}


resource "aws_lb" "l7was" {
  name = "${var.tag}-l7was"
  internal = true
  load_balancer_type = "application"
  ip_address_type = "ipv4"
  security_groups = [aws_security_group.threesg[2].id]
  subnets = data.aws_subnet_ids.pri[0].ids
  tags = { Name = "${var.tag}-l7was"}
}

resource "aws_lb_target_group" "l7groupwas" {
  name = "${var.tag}-l7groupwas"
  port = 8080
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.vpc.id
  health_check {
    protocol = "HTTP"
    path = "/"
  }
  tags = {NAME = "${var.tag}-l7groupwas"}
}

resource "aws_lb_listener" "l7listenwas" {
  load_balancer_arn = aws_lb.l7was.arn
  port = "8080"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.l7groupwas.arn
  }
  tags = {NAME = "${var.tag}-l7listenwas"}
}