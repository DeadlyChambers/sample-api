

// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  ami                         = var.ami
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]
  user_data                   = <<-EOF
                                #!/bin/bash
                                sudo apt-get update
                                sudo apt-get install -y apache2
                                sudo systemctl start apache2
                                sudo systemctl enable apache2
                                echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
                            EOF
  tags = {
    "Name" = "${var.namespace}-EC2-PUBLIC"
  }

}

// Configure the EC2 instance in a private subnet
resource "aws_instance" "ec2_private" {
  ami                         = var.ami
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.private_subnets[1]
  vpc_security_group_ids      = [var.sg_priv_id]

  tags = {
    "Name" = "${var.namespace}-EC2-PRIVATE"
  }

}
