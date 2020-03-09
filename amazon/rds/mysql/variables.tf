variable "aws_region" {
	default = "us-east-2"
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
	default = ["us-east-2a", "us-east-2b"]
}


variable "ami" {
    type = map(string)
    
    default = {
        us-east-2 = "ami-0c64dd618a49aeee8"
        us-east-1 = "ami-0c2a1acae6667e438"
    }
}


variable "default_tags" {
	type = map(string)
    default = {

		Name        = "Application Server"
		Environment = "production"

  }
}


variable "private_key_path" {

	default = "/data/terraform_work/keys/aws-us-east-2"
}

variable "public_key_path" {

	default = "/data/terraform_work/keys/aws-us-east-2.pub"
}


variable "ec2_user" {

	default = "root"
}
