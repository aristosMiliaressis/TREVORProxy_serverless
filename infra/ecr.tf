resource "aws_ecr_repository" "proxy_server" {
  name         = "proxy-server"
  force_delete = true

  tags = {
    Description = "SOCKS proxy server."
  }
}

resource "aws_ecr_lifecycle_policy" "proxy_server" {
  repository = aws_ecr_repository.proxy_server.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 5 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

locals {
  image_tag = "latest"

  dkr_img_src_path   = "${path.module}/src"
  dkr_img_src_sha256 = sha256(join("", [for f in fileset(".", "${local.dkr_img_src_path}/**") : file(f)]))

  dkr_build_cmd = <<-EOT
      docker build -t ${aws_ecr_repository.proxy_server.repository_url}:${local.image_tag} \
           -f ${local.dkr_img_src_path}/Dockerfile --build-arg="SSH_KEY=${var.public_key}" .
  EOT
}

resource "null_resource" "build_push_dkr_img" {
  triggers = {
    detect_docker_source_changes = local.dkr_img_src_sha256
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd
  }
}

resource "docker_registry_image" "proxy_server" {
  name          = "${aws_ecr_repository.proxy_server.repository_url}:${local.image_tag}"
  keep_remotely = true
}
