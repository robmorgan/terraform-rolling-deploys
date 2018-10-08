resource "aws_key_pair" "deployer" {
  key_name   = "demo-developer"
  public_key = "${file("ssh_keys/developer.pub")}"
}
