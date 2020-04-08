resource "alicloud_key_pair" "publickey" {
  key_name   = "alicloud-devops"
  public_key = file(var.public_key_path)
}