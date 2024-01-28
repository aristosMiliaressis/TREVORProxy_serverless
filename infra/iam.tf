resource "aws_iam_role" "proxy_svc" {
  name = "proxy-svc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
          AWS = [
            data.external.caller_identity.result.Arn,
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "grant_ecs_ec2_container_registry_readonly_access" {
  role       = aws_iam_role.proxy_svc.name
  policy_arn = data.aws_iam_policy.ec2_container_registry_readonly.arn
}

data "aws_iam_policy" "ec2_container_registry_readonly" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}