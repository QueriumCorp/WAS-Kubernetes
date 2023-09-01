locals {
  availability_zone = data.aws_subnet.private_subnet.availability_zone
}
data "aws_subnet" "private_subnet" {
  id = var.private_subnet
}
