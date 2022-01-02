resource "aws_db_subnet_group" "rdssubnet" {
  name = "r${var.tag}-rdssubnet"
  subnet_ids = data.aws_subnet_ids.pri[2].ids
  tags = {Name = "${var.tag}-RDSSUBNET"}
}
resource "aws_db_parameter_group" "rdspara" {
  name = "r${var.tag}-rdspara"
  family = "mysql8.0"
  tags = {Name = "${var.tag}-RDSPARA"}
}