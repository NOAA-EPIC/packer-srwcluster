###
# Variables for AWS builders
###

variable "aws_ami_regions" {
  description = "List of regions to copy the AMIs to. Tags and attributes are copied along with the AMIs"
  type        = list(string)
  default     = ["us-east-1","us-east-2","us-west-1","us-west-2"]
}

variable "aws_ami_groups" {
  description = "List of groups that have access to launch the resulting AMIs,`all` will make the AMI publicly accessible"
  type        = list(string)
  default     = []
}

variable "aws_ami_users" {
  description = "List of account IDs that have access to launch the resulting AMI"
  type        = list(string)
  default     = []
}

variable "aws_instance_type" {
  description = "EC2 instance type to use while building the AMIs"
  type        = string
  default     = "c6i.2xlarge"
}

variable "aws_region" {
  description = "Name of the AWS region in which to launch the EC2 instance to create the AMIs"
  type        = string
  default     = "us-east-1"
}

variable "aws_ssh_username" {
  description = "Default user name for EC2 instances"
  type        = string
  default     = "ubuntu"
}

variable "aws_source_ami_filter_ubuntu_2004_hvm" {
  description = "Object with source AMI filters for Ubuntu 20.04"
  type = object({
    name   = string
    owners = list(string)
  })
  default = {
    name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    owners = [
      "099720109477"
    ]
  }
}

variable "aws_temporary_security_group_source_cidrs" {
  description = "List of IPv4 CIDR blocks to be authorized access to the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

###
# Variables for Azure builders
###


###
# Variables for GCP builders
###



###
# Variables used by all platforms
###

variable "root_volume_size" {
  description = "Size in GB of the root volume"
  type        = number
  default     = 230
}


###
# End of variables blocks
###
# Start of source blocks
###

source "amazon-ebs" "base" {
  ami_name                    = "srw-cluster-{{date}}.x86_64-gp3"
  ami_regions                 = var.aws_ami_regions
  ami_users                   = var.aws_ami_users
  ami_groups                  = var.aws_ami_groups
  associate_public_ip_address = true
  communicator                = "ssh"
  ena_support                 = true
  force_deregister            = false
  instance_type               = var.aws_instance_type
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    iops                  = 10000
    throughput            = 1000
  }
  max_retries                           = 20
  sriov_support                         = true
  ssh_port                              = 22
  ssh_pty                               = true
  ssh_timeout                           = "60m"
  ssh_username                          = var.aws_ssh_username
  subnet_id                             = "subnet-04bae583ce498ab48"
  tags                                  = { Name = "SRW-Cluster-{{date}}" }
  temporary_security_group_source_cidrs = var.aws_temporary_security_group_source_cidrs
}

###
# End of source blocks
###
# Start of build blocks
###

build {
  source "amazon-ebs.base" {
    ami_description = "SRW Cluster"
    name            = "SRW-Cluster-Ubuntu-20.04-hvm"
    source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name                = var.aws_source_ami_filter_ubuntu_2004_hvm.name
        root-device-type    = "ebs"
      }
      owners      = var.aws_source_ami_filter_ubuntu_2004_hvm.owners
      most_recent = true
    }
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E '{{ .Path }}'"
    script          = "${path.root}/scripts/srw-cluster-start-script.sh"
  }
}
###
# End of build blocks
###
