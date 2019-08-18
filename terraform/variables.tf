# AWS Config
variable "ssh_private_key" {
        default         = "oracle.pem"
        description     = "Private key for us-east-1"
}

#variable "aws_access_key_env" {
 #default = "${var.aws_access_key_env}"
#}

#variable "aws_secret_access_key_env" {
  #default = "${var.aws_secret_access_key_env}"
#}

variable "aws_region" {
  default = "us-east-1"
}

variable "server_instance_type" {
  default = "t2.micro"
  description = "Instance type"
}
