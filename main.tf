# Configure the AWS Provider
provider "aws" {
  profile = "default"
  shared_credentials_file = "${pathexpand("~/.aws/credentials")}"
  region = "${var.aws_region}"
  version = ">= 1.13.0"

  assume_role {
    role_arn = "${var.profile_role_arn}"
  }
}

# Create an EC2 instance
resource "aws_instance" "spinnaker-k8s-cluster" {
  ami = "ami-0bbc25e23a7640b9b"
  instance_type = "m4.xlarge"
  key_name = "${var.keypair}"

  tags = {
    Name = "Spinnaker-k8s-cluster"
    Environment = "dev"
  }

  security_groups = [aws_security_group.spinnaker_sg.name]

  root_block_device {
    # Storage extenstion for Spinnaker (default 8Gib)
    volume_size = "30"
    volume_type = "gp2"
    # POC: don't need a persistence storage
    delete_on_termination = true
  }

  # Copies resources/hellosvc.yaml file to /tmp/hellosvc.yaml
  provisioner "file" {
    source      = "resources/hellosvc.yaml"
    destination = "/tmp/hellosvc.yaml"
    # SSH Connection details with the ec2
    connection {
      host = self.public_ip
      type = "ssh"
      private_key = "${file(var.private_key)}"
      user = "ec2-user"
    }
  }

  # Copies resources/pipeline.json file to /tmp/pipeline.json
  provisioner "file" {
    source      = "resources/pipeline.json"
    destination = "/tmp/pipeline.json"
    # SSH Connection details with the ec2
    connection {
      host = self.public_ip
      type = "ssh"
      private_key = "${file(var.private_key)}"
      user = "ec2-user"
    }
  }

  # Copies resources/replicaset-v1.yaml file to /tmp/replicaset-v1.yaml
  provisioner "file" {
    source      = "resources/replicaset-v1.yaml"
    destination = "/tmp/replicaset-v1.yaml"
    # SSH Connection details with the ec2
    connection {
      host = self.public_ip
      type = "ssh"
      private_key = "${file(var.private_key)}"
      user = "ec2-user"
    }
  }

  provisioner "remote-exec" {
    # Execute bootstrap script on instance launch to install Minikube, Kubectl and , Helm and to deploy Spinnaker
    script = "bootstrap.sh"
    # SSH Connection details with the ec2 in order to execute bootstrap.sh
    connection {
      host = self.public_ip
      type = "ssh"
      private_key = "${file(var.private_key)}"
      user = "ec2-user"
    }
  }
}

# Security group - only your ip is whitelisted
resource "aws_security_group" "spinnaker_sg" {
  name = "spinnaker_sg"
  description = "Allow SSH inbound traffic"


  # inboud rules
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${data.external.myipaddr.result.ip}/32"]
  }

  # outbound rules
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "spinnaker_sg"
  }

}