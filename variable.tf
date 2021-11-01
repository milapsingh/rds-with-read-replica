variable "vpc_name" {
  default = "<vpc-name>"
}
variable "sg_name" {
  default = "<name>"
}
variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-xxxxxxx", "subnet-xxxxxxx", "subnet-xxxxxxx"]
}

variable "db_engine" {
  default = "aurora-postgresql"
}

variable "engine_version" {
  default = "11.9"
}
variable "instance_class" {
  default = "<type>"
}
variable "reader_instance_class" {
  default = "<type>"
}
variable "name" {
  default = "xxxxx"
}
variable "habitat" {
  default = "xxxx"
}
variable "db_subnet_group_name" {
  default = "<subnet_group_name>"
}

variable "parameter_group_name" {
  default = "default.aurora-postgresql11"
}

variable "maintenance_window" {
  default = "Sun:00:00-Sun:03:00"
}

variable "backup_retention_period" {
  default = "15"
}
variable "preferred_backup_window" {
  default = "00:30-02:30"
}
variable "dns_name" {
  default = "db"
}
variable "reader_dns_name" {
  default = "reader.db"
}
variable "db_snapshot_identifier" {
  default = "<Snapshot-name>"
}
variable "dns_zone_id" {
  default = "<id>"
}
variable "aws_region" {
  default = "ap-south-1"
}
variable "aws_access_key" {
  type = string
}
variable "aws_secret_key" {
  type = string
}
