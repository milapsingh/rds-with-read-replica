data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
                               values = [var.vpc_name]
  }
}
module "sg" {
  source = "./sg"
  vpc_id = data.aws_vpc.selected.id
           name   = var.sg_name
  ingress = [{
    description = "5432 with VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/16"]
    }
  ]
  egress = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
  tags = {
    Name        = var.sg_name
    Provisioner                    = "Terraform"
    Habitat     = var.habitat
  }
}
output "sg" {
  value = module.sg.id
}
resource "aws_db_subnet_group" "default" {
  name       = var.name
  subnet_ids = var.subnet_ids

  tags = {
    Name        = var.name
    Provisioner = "Terrafrom"
    Habitat     = var.habitat
  }
}
resource "aws_db_parameter_group" "default" {
  name   = var.name
  family = "aurora-postgresql11"
}
resource "aws_rds_cluster_parameter_group" "default" {
  name   = var.name
  family = "aurora-postgresql11"
}
resource "aws_rds_cluster" "cluster" {
  cluster_identifier              = var.name
  snapshot_identifier             = var.db_snapshot_identifier
  db_subnet_group_name            = aws_db_subnet_group.default.id
  engine                          = var.db_engine
  engine_version                  = var.engine_version
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.id
  skip_final_snapshot             = true
  vpc_security_group_ids          = module.sg.id
  lifecycle {
    ignore_changes = [snapshot_identifier]
  }
}
resource "aws_rds_cluster_instance" "production" {
  cluster_identifier      = aws_rds_cluster.cluster.id
  identifier              = var.name
  instance_class          = var.instance_class
  db_subnet_group_name    = aws_db_subnet_group.default.id
  availability_zone       = "ap-south-1a"
  engine                  = var.db_engine
  engine_version          = var.engine_version
  db_parameter_group_name = aws_db_parameter_group.default.id
  apply_immediately       = true
  tags = {
    Name        = var.name
    Provisioner = "Terrafrom"
    Habitat     = var.habitat
  }
}

resource "aws_rds_cluster_instance" "production_reader" {
  identifier           = "${var.name}-reader"
  cluster_identifier   = aws_rds_cluster.cluster.id
  instance_class       = var.reader_instance_class
  db_subnet_group_name = aws_db_subnet_group.default.id
  availability_zone    = "ap-south-1a"
  engine               = var.db_engine
  engine_version       = var.engine_version
  tags = {
    Name        = var.name
    Provisioner = "Terrafrom"
    Habitat     = var.habitat
  }
}

resource "aws_route53_record" "db" {
  zone_id = var.dns_zone_id
  name    = var.dns_name
  type    = "CNAME"
  ttl     = "300"
  records = [aws_rds_cluster.cluster.endpoint]
}
resource "aws_route53_record" "db_reader" {
  zone_id = var.dns_zone_id
  name    = var.reader_dns_name
  type    = "CNAME"
  ttl     = "300"
  records = [aws_rds_cluster.cluster.reader_endpoint]
}

output "rds_cluster_endpoint" {
  description = "The cluster endpoint"
  value       = try(aws_rds_cluster.cluster.endpoint, "")
}
output "rds_cluster_reader_endpoint" {
  description = "The cluster endpoint"
  value       = try(aws_rds_cluster.cluster.reader_endpoint, "")
}
