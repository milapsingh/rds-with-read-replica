resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id
  tags   = var.tags
  dynamic "ingress" {
    for_each = var.ingress
    content {
      description     = lookup(ingress.value, "description")
      from_port       = lookup(ingress.value, "from_port", null)
      to_port         = lookup(ingress.value, "to_port", null)
      protocol        = lookup(ingress.value, "protocol", "tcp")
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
    }
  }
  dynamic "egress" {
    for_each = var.egress
    content {
      description     = lookup(egress.value, "description", null)
      from_port       = lookup(egress.value, "from_port", null)
      to_port         = lookup(egress.value, "to_port", null)
      protocol        = lookup(egress.value, "protocol", "tcp")
      cidr_blocks     = lookup(egress.value, "cidr_blocks", null)
      security_groups = lookup(egress.value, "security_groups", null)
    }
  }
}
