# Configure the AWS Provider
provider "aws" {
    region = "us-east-1"
}

# Configure variables
variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}

# Create a VPC
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block 
    tags = {
        Name: "${var.env_prefix}-vpc"   #${var.env_prefix}-vpc, deployment environment prefix ${}, such as: "dev-vpc", "staging-vpc", "prod-vpc"
    }
}

# Create subnet under new created VPC
resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"  #${var.env_prefix}-subnet-1, deployment environment prefix ${}, such as: "dev-subnet-1", "staging-subnet-1", "prod-subnet-1"
    }
}

/* # Create an route table
resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}*/

# Create Internet gateway
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw" 
    }
}

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-main-rtb"
    }
}

resource "aws_default_security_group" "default-sg" {
    
    vpc_id = aws_vpc.myapp-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    # egress (outbound)traffic allow EC2 to connect to outside network and no any restriction 
    egress {
        from_port = 0  #No restriction for port
        to_port = 0
        protocol = "-1"  # Protocal for any
        cidr_blocks = ["0.0.0.0/0"] 
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-default-sg"
    }
}