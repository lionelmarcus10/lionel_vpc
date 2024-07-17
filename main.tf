# réorganiser toute l'architecture

# Define the provider
provider "aws" {
  region     = var.aws_region
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

module "modules" {
  source = "./modules"
}

# Define the security group to allow RDP and VNC access
resource "aws_security_group" "vnc_sg" {
  name        = "vnc_sg"
  description = "Allow RDP and VNC traffic"

  ingress {
    from_port   = 5900
    to_port     = 5900
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the world, change this to restrict access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "rdp_sg" {
  name        = "rdp_sg"
  description = "Allow RDP and VNC traffic"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the world, change this to restrict access
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "all_traffic_sg" {
  name        = "all_traffic_sg"
  description = "Allow all traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Define the resource
resource "aws_instance" "custom_instance" {
  ami           = local.ami_map[terraform.workspace]
  instance_type = var.instance_type
  key_name      = local.key_pair[terraform.workspace]
  tags = {
    Name = "instance-${terraform.workspace}" # Custom name based on workspace
  }
  associate_public_ip_address = true
  security_groups             = terraform.workspace == "buffer-overflow-sandbox" ? [aws_security_group.vnc_sg.name, aws_security_group.rdp_sg.name] : terraform.workspace == "kali-pwnbox" ? [aws_security_group.all_traffic_sg.name] : [aws_security_group.rdp_sg.name]
  user_data                   = terraform.workspace != "buffer-overflow-sandbox" ? null : <<-EOF
    <powershell>
      $url = "https://www.tightvnc.com/download/2.8.81/tightvnc-2.8.81-gpl-setup-64bit.msi"
      $outputPath = "C:\vnc\\tightvnc-2.8.81-gpl-setup-64bit.msi"
      $vncFolder = "C:\\vnc"

      # Create folder if it doesn't exist
      if (-not (Test-Path -Path $vncFolder)) {
          New-Item -ItemType Directory -Path $vncFolder | Out-Null
      }

      # Download the file
      Invoke-WebRequest -Uri $url -OutFile $outputPath

      # Change directory to the "vnc" folder
      Set-Location $vncFolder

      # Execute MSI installation
      Start-Process msiexec -ArgumentList "/i $outputPath /quiet /norestart" -Wait

      # install bufffer overflow sandbox and vnc and redirect to web interface
    </powershell>
  EOF 


}

locals {
  ami_map = {
    buffer-overflow-sandbox = data.aws_ami.windows.id  # Use a Windows AMI
    kali-pwnbox             = data.aws_ami.parrotos.id # Use a Parrot OS AMI
  }
  key_pair = {
    buffer-overflow-sandbox = "buffer-overflow-sandbox-key-pair"
    kali-pwnbox             = "parrot-htb-key-pair"

  }
}

data "aws_ami" "windows" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}


data "aws_ami" "parrotos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Techlatest.net-parrotos-5-gui-linux-v05-marketplace-4c7e87d8-1548-411e-b04d-60b7943d26fc"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["aws-marketplace"]
}
