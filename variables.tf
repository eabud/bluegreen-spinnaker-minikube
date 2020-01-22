variable "aws_region" {
  default = "eu-west-1"
  description = "AWS Region"
}

variable "keypair" {
  default = "Elias"
  description = "Keypair name"
}

variable "profile_role_arn" {
  default = "arn:aws:iam::025318145581:role/MSI.Labs.Role"
  description = "Profile role for ARN"
}

variable "private_key" {
  default = "~/.ssh/Elias.pem"
  description = "Profile role for ARN"
}

data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}