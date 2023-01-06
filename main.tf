
#Stating the provider to use for our infrastructure.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.24"
    }
  }
}

#Setting our default region in aws
provider "aws" {
  region = "us-west-2"
}

#Setting our vpc for the ec2 instance, will use default vpc in our region.
resource "aws_vpc" "default_vpc" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "default_vpc"
  }
}

#Internet gateway which allows us to reach the internet.
#to be connected to the main route table.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default_vpc.id
  tags = {
    Name = "igw"
  }
}

#setting our 3 availability zones for our 3 ec2 instances to be created.
#Setting our subnets.
resource "aws_subnet" "default_az1" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = "172.31.32.0/20"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet for us-west-2a"
  }
}

resource "aws_subnet" "default_az2" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = "172.31.16.0/20"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet for us-west-2b"
  }
}

resource "aws_subnet" "default_az3" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = "172.31.0.0/20"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet for us-west-2c"
  }
}

#creating the route table to go with the internet gateway.
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.default_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}


#Pairing our route tables to our public subnets.
resource "aws_route_table_association" "route2a" {
  subnet_id      = aws_subnet.default_az1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "route2b" {
  subnet_id      = aws_subnet.default_az2.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public2c" {
  subnet_id      = aws_subnet.default_az3.id
  route_table_id = aws_route_table.public_rt.id
}

#setting the security group that allows all traffic to webservers on port 80
# and ssh from my personal IP.
resource "aws_security_group" "HTTP_sg" {
  name        = "HTTP_sg"
  description = "Enable HTTP and SSH access to ec2 instances"
  vpc_id      = aws_vpc.default_vpc.id

  #Allow SSH access.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["50.99.141.44/32"] #my IP
  }

  #Allow incoming HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow outgoing--access to web.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Creating the EC2 Instance
#EC2 Instance 1
resource "aws_instance" "webserver1" {
  ami             = "ami-0ceecbb0f30a902a6"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.default_az1.id
  security_groups = [aws_security_group.HTTP_sg.id]
  key_name        = "TF_projects"

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install nginx1 -y
    sudo systemctl enable nginx
    sudo systemctl start nginx
    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html lang="en">' >> /var/www/html/index.html
    # echo '<head><title>Welcome to Green Team!</title></head>'  >> /var/www/html/index.html
    # echo '<body style="background-color:dark green;">' >> /var/www/html/index.html
    echo '<h1 style="color:white;">This is my nginx Webserver in AZ1!</h1>' >> /var/www/html/index.html
    EOF

  tags = {
    Name = "nginxwebserver1"
  }
}

#EC2 Instance 2
resource "aws_instance" "webserver2" {
  ami             = "ami-0ceecbb0f30a902a6"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.default_az2.id
  security_groups = [aws_security_group.HTTP_sg.id]
  key_name        = "TF_projects"

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install nginx1 -y
    sudo systemctl enable nginx
    sudo systemctl start nginx
    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html lang="en">' >> /var/www/html/index.html
    # echo '<head><title>Welcome to Green Team!</title></head>'  >> /var/www/html/index.html
    # echo '<body style="background-color:dark green;">' >> /var/www/html/index.html
    echo '<h1 style="color:white;">This is my nginx Webserver in AZ2!</h1>' >> /var/www/html/index.html
    EOF

  tags = {
    Name = "nginxwebserver2"
  }
}

#EC2 Instance 3
resource "aws_instance" "webserver3" {
  ami             = "ami-0ceecbb0f30a902a6"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.default_az3.id
  security_groups = [aws_security_group.HTTP_sg.id]
  key_name        = "TF_projects"

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install nginx1 -y
    sudo systemctl enable nginx
    sudo systemctl start nginx
    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html lang="en">' >> /var/www/html/index.html
    # echo '<head><title>Welcome to Green Team!</title></head>'  >> /var/www/html/index.html
    # echo '<body style="background-color:dark green;">' >> /var/www/html/index.html
    echo '<h1 style="color:black;">This is my nginx Webserver in AZ3!</h1>' >> /var/www/html/index.html
    EOF

  tags = {
    Name = "nginxwebserver3"
  }
}
