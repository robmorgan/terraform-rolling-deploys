/* NAT/VPN server */
resource "aws_eip" "nat" {
  instance = "${aws_instance.nat.id}"
  vpc      = true
}

resource "aws_instance" "nat" {
  ami           = "${lookup(var.amis, var.aws_region)}"
  instance_type = "t2.micro"

  # deploy the nat instance into the first availability zone
  subnet_id = "${aws_subnet.public_az1.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}", "${aws_security_group.nat.id}"]

  key_name          = "${aws_key_pair.deployer.key_name}"
  source_dest_check = false

  tags = {
    Name = "nat"
  }

  connection {
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo iptables -t nat -A POSTROUTING -j MASQUERADE",
      "echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward",

      /* Install docker */
      "curl -sSL https://get.docker.com/ | sudo sh",

      /* Initialize open vpn data container */
      "sudo mkdir -p /etc/openvpn",

      "sudo docker run --name ovpn-data -v /etc/openvpn busybox",

      /* Generate OpenVPN server config */
      "sudo docker run --volumes-from ovpn-data --rm mb/openvpn ovpn_genconfig -p ${var.vpc_cidr} -u udp://${aws_instance.nat.public_ip}",
    ]
  }
}
