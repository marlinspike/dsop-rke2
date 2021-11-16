output "rke2_cluster" {
  value = module.rke2_cluster.cluster_data
}

output "kv_name" {
  value = module.rke2_cluster.token_vault_name
}

output "rg_name" {
  value = local.resource_group_name
}
