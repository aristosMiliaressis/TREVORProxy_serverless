variable "profile" {
  description = "The local AWS configuration profile to use."
  type        = string

  default = "default"
}

variable "message_retention_seconds" {
  description = "The SQS message retention in seconds (serves as hard timeout for proxy intent messages)."
  type        = number

  default = 7200 # 2 hours
}

variable "proxy_count" {
  description = "The number of SOCKS proxies to spin up."
  type        = number

  default = 20
}

variable "public_key" {
  description = "The SSH public key."
  type        = string
}