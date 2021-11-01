# rds-with-readreplica

There is no proper documentation on terraform if you want to create RDS aurora with one reader
You can follow this code and you'll able to create one reader, one writer cluster along with Route53 entry 

With the help of this you can create RDS aurora postgres with terraform 
Terraform RDS aurora cluster with one read replica 

Create RDS cluster 
```
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
```

Create RDS cluster instance : 
```
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
```
Create RDS cluster reader instance : 
```
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
```
