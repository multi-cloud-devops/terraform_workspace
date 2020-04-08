variable "aws_region" {
	default = "us-east-1"
}

variable "vpc_cidr" {
	default = "10.20.0.0/16"
}

variable "subnets_cidr" {
	type = list(string)
	default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "azs" {
	type = list(string)
	default = ["us-east-1a", "us-east-1b"]
}


variable "ami" {
    type = map(string)
    
    default = {
        us-east-1 = "ami-0c2a1acae6667e438"
		    us-east-2 = "ami-0c64dd618a49aeee8"
    }
}


variable "public_key_path" {

	default = "/data/etc/alicloud/devops.pub"
}

variable "instance_tags" {
  description = "Used to mark specified ecs instance."

  type = list(map(any))

  default = [
    {
      key                 = "project_name"
      value               = "project1"
      propagate_at_launch = true
    },
    {
      key                 = "cluster_name"
      value               = "cluster1"
      propagate_at_launch = true
    }
  ]

}





