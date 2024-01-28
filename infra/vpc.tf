resource "aws_vpc" "this" {
  cidr_block                       = "10.10.0.0/16"
  assign_generated_ipv6_cidr_block = true
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  depends_on = [
    aws_subnet.public
  ]
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.this.id

  cidr_block                      = cidrsubnet(aws_vpc.this.cidr_block, 4, 1)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 1)
  assign_ipv6_address_on_creation = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "this" {
  name   = "socks-proxy-sg"
  vpc_id = aws_vpc.this.id

  ingress = [
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "allow-ssh"
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    }
  ]

  depends_on = [
    aws_internet_gateway.this
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}