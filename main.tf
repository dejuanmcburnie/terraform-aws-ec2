data "aws_ami" "amazon_linux_2023" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "al2023-ami-*-x86_64"
    ]
  }

  filter {
    name = "architecture"
    values = [
      "x86_64"
    ]
  }

  filter {
    name = "virtualization-type"
    values = [
      "hvm"
    ]
  }
}

locals {
  selected_ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux_2023[0].id

  common_tags = merge(
    var.tags,
    {
      Name      = var.name
      ManagedBy = "terraform"
      Module    = "terraform-aws-ec2-instance"
    }
  )
}

data "aws_iam_role" "ssm" {
  name = "AmazonSSMRoleForInstancesQuickSetup"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.name}-ssm-instance-profile"
  role = data.aws_iam_role.ssm.name
}

resource "aws_instance" "deployec2" {
  ami                         = local.selected_ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data

  iam_instance_profile = aws_iam_instance_profile.ssm.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = true

    tags = local.common_tags
  }

  tags = local.common_tags
}
