# create iam policies


# IAM Role for EC2 Image Builder
resource "aws_iam_role" "image_builder_role" {
  name = "image-builder-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "imagebuilder.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

# IAM Policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-access-policy"
  description = "Policy for EC2 instances to access S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket}",
          "arn:aws:s3:::${var.s3_bucket}/*"
        ]
      },
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.image_builder_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "image_builder_instance_profile" {
  name = "image-builder-instance-profile"
  role = aws_iam_role.image_builder_role.name
}
