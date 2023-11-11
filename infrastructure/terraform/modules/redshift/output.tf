output "arn" {
  value = aws_redshift_cluster.redshift_cluster.arn

}
output "id" {
  value = aws_redshift_cluster.redshift_cluster.id

}

output "cluster_identifier" {
  value = aws_redshift_cluster.redshift_cluster.cluster_identifier

}

output "db_name" {
  value = aws_redshift_cluster.redshift_cluster.database_name

}

output "endpoint" {
  value = aws_redshift_cluster.redshift_cluster.endpoint

}
output "redshift_port" {
  value = aws_redshift_cluster.redshift_cluster.port

}
output "master_username" {
  value = aws_redshift_cluster.redshift_cluster.master_username

}
output "master_password" {
  value = aws_redshift_cluster.redshift_cluster.master_password

}
output "redshift_iam_arn" {
  value = aws_iam_role.redshift_iam_role.arn

}
