variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "kasey-aws-krishna"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID for eu-west-1"
  type        = string
  default     = "ami-09d95fab7fff3776c"
}
