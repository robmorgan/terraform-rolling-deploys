resource "aws_key_pair" "deployer" {
  key_name   = "demo-rmorgan"
  public_key = "${file("ssh_keys/deployer.pub")}"
}
