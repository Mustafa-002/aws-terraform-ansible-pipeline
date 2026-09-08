variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}
