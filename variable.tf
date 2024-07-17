variable "aws_region" {
  description = "The AWS region to deploy the instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type"
  type        = string
}

variable "AWS_SECRET_KEY" {
  description = "The AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "AWS_ACCESS_KEY" {
  description = "The AWS Access Key"
  type        = string
  sensitive   = true
}

variable "s3_bucket" {
  description = "The S3 bucket to store the ISO file"
  type        = string
}

variable "iso_file" {
  description = "The ISO file to download"
  type        = string
}
