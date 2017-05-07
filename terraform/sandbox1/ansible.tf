
#==========================================================================

##
# The variables for this infrasturcture

# The region for AWS
variable "region" {
  type = "string"
  default = "us-east-2"
}

# The availability zone (which is just the region + leter-code )
variable "azone" {
  type = "string"
  default = "us-east-2a"
}

# The key-pair used to crete instances
variable "keypair_name" {
  type = "string"
  default = "33x.sandbox-dev"
}


#==========================================================================


##
# Setup AWS provider to default to us-east-2 and use a profile
provider "aws" {
  profile    = "33x.sandbox-dev"
  region     = "${var.region}"
}

#==========================================================================

##
# The public/private key pairs used for AWS EC2


#==========================================================================

##
# The differetn security groups in AWS
resource "aws_security_group" "allow_ssh_anywhere" {
  name_prefix = "allow_ssh_anywhere"
  description = "Allows SSH port 22 ingress from anywhere"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self = "true"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self = "true"
  }

  tags {
    name = "allow_ssh_anywhere"
    system = "sandbox1"
  }
}

#==========================================================================

##
# These are EBS block devices used as disks and mounted into our instances
# Tehse are jsut hte definitions of these volumes, the attachment mapping
# is done below

resource "aws_ebs_volume" "ansible-controller" {
  availability_zone = "${var.azone}"
  size = 5
  tags {
    role = "ansible-controller"
    system = "sandbox1"
  }
}


#==========================================================================

##
# Here the the EC2 Instances that we will create/maintain


##
# The Ansible Controller. This is a single, tiny instance that is
# needed to simply run the ansible command-line.
# It just needs the ability to openssh to other nodes in the
# system :)

# The ansible contorller isntance
resource "aws_instance" "ansible-controller" {
  ami           = "ami-e086a285"
  instance_type = "t2.micro"
  availability_zone = "${var.azone}"

  key_name = "${var.keypair_name}"

  security_groups = [ "${aws_security_group.allow_ssh_anywhere.name}" ]

  tags {
    role = "ansible-controller"
    system = "sandbox1"
  }
}

# attach a volume to hte ansible controller instance
resource "aws_volume_attachment" "ebs_attach_ansible-control" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.ansible-controller.id}"
  instance_id = "${aws_instance.ansible-controller.id}"
}

#==========================================================================

##
# The outputs for this infrasructure

# output the public DNS name of our ansible controller
output "ansible-controller-dns" {
  value = "${aws_instance.ansible-controller.public_dns}"
}


#==========================================================================
