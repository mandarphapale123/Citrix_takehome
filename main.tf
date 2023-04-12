#Create EC2 instance
resource "aws_instance" "security_agent" {
  ami                     = "ami-081a3b9eded47f0f3"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = ["${aws_security_group.ec2-sg.id}"]
  subnet_id               = "${aws_subnet.subnet-uno.id}"
  key_name                = "TF_sshkey"
  tags = {
    Name = "security_agent"
  }
}


resource "aws_key_pair" "TF_sshkey" {
  key_name   = "TF_sshkey"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-sshkey" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfsshkey.pem"
}

resource "aws_security_group" "ec2-sg" {
  name        = "ec2-sg"
  vpc_id      = "${aws_vpc.myvpc.id}"

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}


#Create a VPC
resource "aws_vpc" "myvpc"{
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "MyVPC"
  }
}

resource "aws_eip" "ip-test-env" {
  instance = "${aws_instance.security_agent.id}"
  vpc      = true
}

//subnets.tf
resource "aws_subnet" "subnet-uno" {
  cidr_block = "${cidrsubnet(aws_vpc.myvpc.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.myvpc.id}"
  availability_zone = "us-west-1b"
}

#create IGW
resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags = {
    Name = "test-env-gw"
  }
}

#route Tables for public subnet
resource "aws_route_table" "route-table-test-env" {
  vpc_id = "${aws_vpc.myvpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-gw.id}"
  }
  tags = {
    Name = "test-env-route-table"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-uno.id}"
  route_table_id = "${aws_route_table.route-table-test-env.id}"
}