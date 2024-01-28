resource "aws_ecs_cluster" "this" {
  name = "proxy-cluster"
}

resource "aws_ecs_task_definition" "proxy_def" {
  family                   = "proxy-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.proxy_svc.arn
  task_role_arn            = aws_iam_role.proxy_svc.arn

  container_definitions = <<DEFINITION
  [
    {
      "name": "proxy",
      "image": "${docker_registry_image.proxy_server.name}",
      "essential": true,
      "stopTimeout": 120
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "proxy_svc" {
  name            = "proxy-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.proxy_def.arn
  desired_count   = 0
  depends_on = [
    aws_ecs_cluster.this,
    aws_security_group.this,
    aws_ecs_task_definition.proxy_def,
    aws_iam_role.proxy_svc
  ]

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = true
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
