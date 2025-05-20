
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_id
  enable_dns_hostnames = true

  tags = {
    Name        = var.vpc_name
    Environment = "project_env"
    terraform   = "true"
  }

}
data "aws_availability_zones" "all_available_zones" {
  state = "available"

}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "project_igw"
  }

}
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = data.aws_availability_zones.all_available_zones.names[0]
  tags = {
    Name      = "public_subnet"
    terraform = "true"
  }

}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name      = "project_public_rtb"
    terraform = "true"
  }

}
resource "aws_route_table_association" "route_table_association" {

  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
  depends_on     = [aws_subnet.public_subnet]

}

resource "aws_security_group" "jenkins_sg" {
  name   = "jenkins-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }
  # We want the Jenkins EC2 instance to being able to talk to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins_sg"
  }
}
resource "aws_key_pair" "raed-key" {
  key_name   = "raed-key"
  public_key = file("~/ssh/raed-key.pub")
}
data "aws_ami" "ubuntu" {
  most_recent = "true"
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]

}
resource "aws_instance" "jenkins" {

  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  instance_type          = "t2.micro"
  key_name               = "raed-key"
  availability_zone      = data.aws_availability_zones.all_available_zones.names[0]
  subnet_id              = aws_subnet.public_subnet.id
  root_block_device {
    encrypted = true
  }
  user_data = file("${path.module}/jenkins-server-installition.sh")
  tags = {
    Name = "jenkins-instance"
  }


}
resource "aws_eip" "eip" {

  instance = aws_instance.jenkins.id
  domain   = "vpc"
  tags = {
    Name = "instance_eip"
  }

}