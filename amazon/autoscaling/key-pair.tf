resource "aws_key_pair" "publickey" {
  key_name   = "aws-devops"
  public_key = file(var.public_key_path)
}