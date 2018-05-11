resource "aws_elb" "elb_app" {
  name = "app-elb"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 15
  }

  cross_zone_load_balancing = true
  idle_timeout              = 60
  subnets                   = ["${aws_subnet.public_az1.id}", "${aws_subnet.public_az2.id}", "${aws_subnet.public_az3.id}"]
  security_groups           = ["${aws_security_group.elb_web.id}"]

  tags {
    Name = "app-elb"
  }
}

resource "aws_autoscaling_group" "asg_app" {
  lifecycle {
    create_before_destroy = true
  }

  # interpolate the LC into the ASG name so it always forces an update
  name                      = "asg-app - ${aws_launch_configuration.lc_app.name}"
  max_size                  = 5
  min_size                  = 2
  wait_for_elb_capacity     = 2
  desired_capacity          = 2
  health_check_grace_period = 150
  health_check_type         = "ELB"
  launch_configuration      = "${aws_launch_configuration.lc_app.id}"
  load_balancers            = ["${aws_elb.elb_app.id}"]

  # spread the app instances across the availability zones
  vpc_zone_identifier = ["${aws_subnet.private_az1.id}", "${aws_subnet.private_az2.id}", "${aws_subnet.private_az3.id}"]

  tag {
    key                 = "Name"
    value               = "app${count.index}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "lc_app" {
  lifecycle {
    create_before_destroy = true
  }

  image_id      = "${var.ami}"
  instance_type = "c4.large"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.default.id}", "${aws_security_group.app.id}"]

  user_data = "${file("user_data/app-server.sh")}"
}
