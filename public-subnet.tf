/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

/* Public subnets */
resource "aws_subnet" "public_az1" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.public_subnet_az1_cidr}"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.default"]
  tags {
    Name = "public az1"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.public_subnet_az2_cidr}"
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.default"]
  tags {
    Name = "public az2"
  }
}

resource "aws_subnet" "public_az3" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.public_subnet_az3_cidr}"
  availability_zone = "eu-west-1c"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.default"]
  tags {
    Name = "public az3"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

/* Associate the routing table to public subnets */
resource "aws_route_table_association" "public_az1" {
  subnet_id = "${aws_subnet.public_az1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_az2" {
  subnet_id = "${aws_subnet.public_az2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_az3" {
  subnet_id = "${aws_subnet.public_az3.id}"
  route_table_id = "${aws_route_table.public.id}"
}
