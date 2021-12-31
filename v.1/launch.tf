resource "aws_launch_template" "luanchweb" {
  name = "${var.tag}-luanchweb"
  image_id = data.aws_ami.al2.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  tags = {Name = "${var.tag}-luanchweb"}
  update_default_version = true
  network_interfaces {
      associate_public_ip_address = true
      delete_on_termination = true
      security_groups = [ "${aws_security_group.threesg[1].id}" ]
  }
  iam_instance_profile {
      name = aws_iam_instance_profile.ec2-ssm.name
  }
  tag_specifications {
      resource_type = "instance"
      tags = {Name = "${var.tag}-webinstance"}
  }
  tag_specifications {
      resource_type = "volume"
      tags = {Name = "${var.tag}-webvolume"}
  } 
}

resource "aws_launch_template" "luanchwas" {
  name = "${var.tag}-luanchwas"
  image_id = data.aws_ami.al2.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  tags = {Name = "${var.tag}-luanchwas"}
  update_default_version = true
  network_interfaces {
      associate_public_ip_address = true
      delete_on_termination = true
      security_groups = [ "${aws_security_group.threesg[3].id}" ]
  }
  iam_instance_profile {
      name = aws_iam_instance_profile.ec2-ssm.name
  }
  tag_specifications {
      resource_type = "instance"
      tags = {Name = "${var.tag}-wasinstance"}
  }
  tag_specifications {
      resource_type = "volume"
      tags = {Name = "${var.tag}-wasvolume"}
  }
}