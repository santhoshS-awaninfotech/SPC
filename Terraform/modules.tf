
module "aws_resources_for_region1" {
  count              = var.cloud == "AWS" ? 1 : 0
  source             = "./AWS"
  providers          = { aws = aws.reg1 }
  module_name        = "aws_resources_for_region1"
  cloud              = var.cloud
  region             = var.region1
  region_code        = var.region1_code
  backendvm_count    = local.region_settings[var.region1].backendvm_count
  discvm_count       = local.region_settings[var.region1].discvm_count
  vpc_cidr           = var.vpc_cidr
  backsubnet_cidr    = var.backsubnet_cidr
  discsubnet_cidr    = var.discsubnet_cidr
  disc_instance_type = var.disc_instance_type
  be_instance_type   = var.be_instance_type
  pgsql_password     = var.pgsql_password
  admin_password     = var.admin_password
  userA_password     = var.userA_password
  userB_password     = var.userB_password
}

module "aws_resources_for_region2" {
  count              = var.cloud == "AWS" ? 1 : 0
  source             = "./AWS"
  providers          = { aws = aws.reg2 }
  module_name        = "aws_resources_for_region2"
  cloud              = var.cloud
  region             = var.region2
  region_code        = var.region2_code
  backendvm_count    = local.region_settings[var.region2].backendvm_count
  discvm_count       = local.region_settings[var.region2].discvm_count
  vpc_cidr           = var.vpc_cidr
  backsubnet_cidr    = var.backsubnet_cidr
  discsubnet_cidr    = var.discsubnet_cidr
  disc_instance_type = var.disc_instance_type
  be_instance_type   = var.be_instance_type
  pgsql_password     = var.pgsql_password
  admin_password     = var.admin_password
  userA_password     = var.userA_password
  userB_password     = var.userB_password
}

module "azure_resources" {
  source         = "./Azure"
  count          = var.cloud == "Azure" ? 1 : 0
  cloud          = var.cloud
  pgsql_password = var.pgsql_password
  admin_password = var.admin_password
  userA_password = var.userA_password
  userB_password = var.userB_password
}

output "backend_ip_map_region1" {
  value = module.aws_resources_for_region1[0].backend_ip_map
}

output "discovery_ip_map_region1" {
  value = module.aws_resources_for_region1[0].discovery_ip_map
}
output "backend_ip_map_region2" {
  value = module.aws_resources_for_region2[0].backend_ip_map
}

output "discovery_ip_map_region2" {
  value = module.aws_resources_for_region2[0].discovery_ip_map
}