output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the project VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_app_subnet_a_id" {
  description = "ID of private application subnet A"
  value       = aws_subnet.private_app_a.id
}

output "private_app_subnet_b_id" {
  description = "ID of private application subnet B"
  value       = aws_subnet.private_app_b.id
}

output "private_db_subnet_a_id" {
  description = "ID of private database subnet A"
  value       = aws_subnet.private_db_a.id
}

output "private_db_subnet_b_id" {
  description = "ID of private database subnet B"
  value       = aws_subnet.private_db_b.id
}

output "db_subnet_group_name" {
  description = "Name of the RDS DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

output "app_security_group_id" {
  description = "Security group ID for application servers"
  value       = aws_security_group.app.id
}

output "alb_security_group_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = aws_security_group.alb.id
}
