terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.19.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region = var.region
}

resource "aws_instance" "k8s" {
  ami = var.ami
  instance_type = "t2.medium"
#  vpc_id = var.vpc_id
  vpc_security_group_ids = [var.security_group_id]
  subnet_id = var.subnet_id
  key_name = var.key_name
  root_block_device {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name ="maxrodkin_jumpbox_2"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }
  user_data = <<EOF
#!/bin/bash
git clone https://github.com/maxrodkin/tf-k8s-helm-nginx-prometheus-grafana-flask.git \
&& cd tf-k8s-helm-nginx-prometheus-grafana-flask
./install.sh  

EOF

}


output "ec2instance" {
  value = aws_instance.k8s.public_dns
  }