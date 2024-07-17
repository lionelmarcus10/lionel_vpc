variable "s3_bucket" {
  description = "The S3 bucket to store the ISO file"
  type        = string
}

variable "iso_file" {
  description = "The ISO file to download"
  type        = string
}
