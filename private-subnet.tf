/* Private subnet */
resource "aws_subnet" "private_az1" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_az1_cidr}"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = false
  depends_on = ["aws_instance.nat"]
  tags {
    Name = "private az1"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_az2_cidr}"
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = false
  depends_on = ["aws_instance.nat"]
  tags {
    Name = "private az2"
  }
}

resource "aws_subnet" "private_az3" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_az3_cidr}"
  availability_zone = "eu-west-1c"
  map_public_ip_on_launch = false
  depends_on = ["aws_instance.nat"]
  tags {
    Name = "private az3"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }
}

/* Associate the routing table to public subnets */
resource "aws_route_table_association" "private_az1" {
  subnet_id = "${aws_subnet.private_az1.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_az2" {
  subnet_id = "${aws_subnet.private_az2.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_az3" {
  subnet_id = "${aws_subnet.private_az3.id}"
  route_table_id = "${aws_route_table.private.id}"
}
