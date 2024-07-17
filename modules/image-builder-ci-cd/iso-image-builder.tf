# build images

# EC2 Image Builder Component
resource "aws_imagebuilder_component" "iso_install_component" {
  name     = "iso-install-component"
  version  = "1.0.0"
  platform = "Linux"
  data     = <<EOT
name: InstallFromISO
description: Install software from an ISO file
schemaVersion: 1.0
phases:
  - name: build
    steps:
      - name: DownloadAndMountISO
        action: ExecuteBash
        inputs:
          commands:
            - aws s3 cp s3://${var.s3_bucket}/${var.iso_file} /mnt/${var.iso_file}
            - mkdir -p /mnt/iso
            - mount -o loop /mnt/${var.iso_file} /mnt/iso
            - cp -r /mnt/iso/* /destination-path/
            - umount /mnt/iso
            - rm /mnt/${var.iso_file}
EOT
}

# Image Recipe
resource "aws_imagebuilder_image_recipe" "image_recipe" {
  name         = "custom-image-recipe"
  version      = "1.0.0"
  parent_image = "ami-0abcdef1234567890" # Base AMI ID
  component {
    component_arn = aws_imagebuilder_component.iso_install_component.arn
  }
  block_device_mapping {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      delete_on_termination = true
      volume_type           = "gp2"
    }
  }
}

# Infrastructure Configuration
resource "aws_imagebuilder_infrastructure_configuration" "infrastructure_config" {
  name                          = "image-builder-infrastructure"
  instance_profile_name         = aws_iam_instance_profile.image_builder_instance_profile.name
  security_group_ids            = ["sg-0123456789abcdef0"]   # Your security group ID
  subnet_id                     = "subnet-0123456789abcdef0" # Your subnet ID
  terminate_instance_on_failure = true
}

# Image Pipeline
resource "aws_imagebuilder_image_pipeline" "image_pipeline" {
  name                             = "custom-image-pipeline"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.image_recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.infrastructure_config.arn
  status                           = "ENABLED"
  schedule {
    schedule_expression = "cron(0 0 * * ? *)" # Daily at midnight
  }
}
