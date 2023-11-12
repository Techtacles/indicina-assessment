resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier  = var.cluster_identifier
  database_name       = var.database_name
  master_username     = var.master_username
  master_password     = var.master_password
  node_type           = "dc2.large"
  cluster_type        = "single-node"
  skip_final_snapshot = true

}
