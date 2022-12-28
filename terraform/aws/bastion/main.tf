data "aws_ami" "default" {
  most_recent = "true"

  filter {
    name   = "name"
    values = ["${var.toolset_ami_name}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.toolset_ami_owner]
}

locals {
  ami_id        = data.aws_ami.default.id
  disk_size     = 80
  instance_type = var.vm_size
  username      = "ubuntu"
}

resource "aws_eip" "provisioner" {
  vpc      = true
  instance = aws_instance.provisioner.id
}

resource "aws_instance" "provisioner" {
  ami                    = local.ami_id
  instance_type          = local.instance_type
  key_name               = var.ssh_key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.provisioner_security_group_id, var.eks_cluster_security_group_id]

  root_block_device {
    volume_size           = local.disk_size
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
