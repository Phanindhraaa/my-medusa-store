provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "medusa-vpc"
  }
}

# Internet Gateway
#resource "aws_internet_gateway" "gw" {
#  vpc_id = aws_vpc.main.id
#  tags = {
 #   Name = "medusa-igw"
 # }
#}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "medusa-public-subnet"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}


# Security Group for ECS Task
resource "aws_security_group" "medusa_sg" {
  name        = "medusa-sg"
  description = "Allow Medusa HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Task Definition
#resource "aws_ecs_task_definition" "medusa" {
 # family                   = "medusa-task"
  #network_mode             = "awsvpc"
  #requires_compatibilities = ["FARGATE"]
  #cpu                      = "512"
  #memory                   = "1024"
  #execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
#
  #container_definitions = jsonencode([{
   # name      = "medusa"
   # image     = "medusajs/medusa:latest"
    #portMappings = [{
     # containerPort = 9000
      #protocol      = "tcp"
   # }]
    #environment = [
     # {
      #  name  = "NODE_ENV"
       # value = "development"
     # },
     # {
       # name  = "DATABASE_URL"
        #value = "postgres://postgres:medusa123@REPLACE_ME:5432/postgres"
      #}
    #]
 # }])
#}

# ECS Service
#resource "aws_ecs_service" "medusa" {
 # name            = "medusa-service"
  #cluster         = aws_ecs_cluster.main.id
  #launch_type     = "FARGATE"
 # desired_count   = 1
  #task_definition = aws_ecs_task_definition.medusa.arn
#
 # network_configuration {
  #  subnets          = [aws_subnet.public.id]
   # assign_public_ip = true
    #security_groups  = [aws_security_group.medusa_sg.id]
  #}

 # depends_on = [
    
 # ]
#}
resource "aws_db_instance" "medusa_db" {
  identifier         = "medusa-db"
  allocated_storage  = var.db_allocated_storage
  engine             = "postgres"
  engine_version     = "14"
  instance_class     = var.db_instance_class
  db_name            = var.db_name
  username           = var.db_username
  password           = var.db_password
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.medusa_sg.id]
 # db_subnet_group_name   = aws_db_subnet_group.medusa_subnet_group.name

  publicly_accessible = true

  tags = {
    Name = "medusa-postgres"
  }
}
#resource "aws_db_subnet_group" "medusa_subnet_group" {
 # name       = "medusa-db-subnet-group"
  #  subnet_ids = [
   # aws_subnet.public.id,
   # aws_subnet.public_2.id
  #]

  #tags = {
   # Name = "medusa-db-subnet-group"
 # }
#}
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

