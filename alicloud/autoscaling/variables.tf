variable "profile" {
  default = "default"
}
variable "region" {
  default = "cn-hangzhou"
}


variable "vpc_cidr" {
	default = "10.20.0.0/16"
}

variable "subnets_cidr" {
	type = string
	default = "10.20.0.0/16"
}

variable "azs" {
	type = string
	default = "cn-hangzhou-b"
}


variable "public_key_path" {

	default = "/data/etc/alicloud/devops.pub"
}


variable "instance_tags" {
  description = "Used to mark specified ecs instance."
  type        = map(string)

  default = {
    project_name   = "project1"
    cluster_name = "cluster1"
  }
}
