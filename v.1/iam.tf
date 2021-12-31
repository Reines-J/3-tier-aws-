resource "aws_iam_role" "threetier" {
  name = "${var.tag}-ssm"
  path = "/" 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role = aws_iam_role.threetier.name
}

resource "aws_iam_instance_profile" "ec2-ssm" {
  name = "ec2-ssm"
  role = aws_iam_role.threetier.name
}