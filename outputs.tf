output "nat.ip" {
  value = "${aws_instance.nat.public_ip}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.asg_app.id}"
}

output "elb_name" {
  value = "${aws_elb.elb_app.dns_name}"
}

output "url" {
  value = "http://${aws_elb.elb_app.dns_name}"
}
