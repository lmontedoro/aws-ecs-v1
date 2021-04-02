# Cluster 
resource "aws_ecs_cluster" "cluster" { 
    name = "${var.prefix}-cluster" 
    tags = merge(var.tags, { 
        "Name" = "${var.prefix}-cluster", 
    }) 
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.prefix}-log-group"
  tags = merge(var.tags, {
    "Name" = "${var.prefix}-log-group",
  })
}

# ECS Task Role
resource "aws_iam_role" "taskexecution_role" {
  name        = "${var.prefix}-ecs-taskexecution-role"
  description = "Role to ECS Task"

  assume_role_policy = data.aws_iam_policy_document.ecstask_assume_role.json

  tags = merge(var.tags, {
    "Name" = "${var.prefix}-ecs-taskexecution-role",
  })
}

# ECS Assume Role Policy Document
data "aws_iam_policy_document" "ecstask_assume_role" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Attach AmazonECSTaskExecutionRolePolicy 
resource "aws_iam_role_policy_attachment" "ECSTaskExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.taskexecution_role.name
}

# Task Security Group
resource "aws_security_group" "task-sg" {
  name        = "${var.prefix}-task-sg"
  description = "Security Group to allow connections to port 80"
  vpc_id      = var.vpcid

  tags = merge(var.tags, {
    "Name" = "${var.prefix}-task-sg",
  })

  ingress {
    from_port   = 80
    to_port     = 80
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
resource "aws_ecs_task_definition" "task" {
  family             = "${var.prefix}-task-definition"
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.taskexecution_role.arn
  task_role_arn      = aws_iam_role.taskexecution_role.arn

  tags = merge(var.tags, {
    "Name" = "${var.prefix}-task-definition"
  })

  container_definitions    = <<DEFINITION
  [
    {
      "name": "myweb",
      "image": "${var.ecr_image}",
      "portMappings": [
        {
            "containerPort": 80,
            "hostPort": 80
        }
      ],
      "logConfiguration": {
      "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.log_group.name}",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "awslogs-myweb"
        }
      }
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "${var.prefix}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.subnet]
    security_groups  = [aws_security_group.task-sg.id]
    assign_public_ip = true
  }
}


