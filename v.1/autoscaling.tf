resource "aws_autoscaling_group" "exelbgroup" {
  name = "${var.tag}-exelb"
  desired_capacity = 2
  min_size = 2
  max_size = 2
  health_check_grace_period = 60
  health_check_type = "ELB"
  force_delete = true
  vpc_zone_identifier = data.aws_subnet_ids.pri[0].ids
  target_group_arns = ["${aws_lb_target_group.l7groupweb.arn}"]
  launch_template {
    id = aws_launch_template.luanchweb.id
    version = "$Latest"
  }
  tags = [ {
    "Name" = "${var.tag}-exelbgroup"
  } ]
}

resource "aws_autoscaling_policy" "exelbpolicy" {
  name = "${var.tag}-exelb"
  adjustment_type = "PercentChangeInCapacity"
  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup = 60
  autoscaling_group_name = aws_autoscaling_group.exelbgroup.name
  target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 30
  }
}

resource "aws_autoscaling_attachment" "exelbattach" {
  autoscaling_group_name = aws_autoscaling_group.exelbgroup.name
}

resource "aws_autoscaling_group" "inelbgroup" {
  name = "${var.tag}-inelb"
  desired_capacity = 2
  min_size = 2
  max_size = 2
  health_check_grace_period = 60
  health_check_type = "ELB"
  force_delete = true
  vpc_zone_identifier = data.aws_subnet_ids.pri[1].ids
  target_group_arns = ["${aws_lb_target_group.l7groupwas.arn}"]
  launch_template {
    id = aws_launch_template.luanchwas.id
    version = "$Latest"
  }
  tags = [ {
    "Name" = "${var.tag}-inelbgroup"
  } ]
}

resource "aws_autoscaling_policy" "inelbpolicy" {
  name = "${var.tag}-inelb"
  adjustment_type = "PercentChangeInCapacity"
  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup = 60
  autoscaling_group_name = aws_autoscaling_group.inelbgroup.name
  target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 30
  }
}

resource "aws_autoscaling_attachment" "inelbattach" {
  autoscaling_group_name = aws_autoscaling_group.inelbgroup.name
}