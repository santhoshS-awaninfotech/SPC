
# module "aws_resources" {
#   source             = "./AWS"
#   #count              = var.cloud == "AWS" ? 1 : 0
#   for_each = var.cloud == "AWS" ? var.regions : {}
#   providers = {
#     aws = aws[each.key]
#   }
#   cloud              = var.cloud
#   vpc_cidr           = var.vpc_cidr
#   backsubnet_cidr    = var.backsubnet_cidr
#   discsubnet_cidr    = var.discsubnet_cidr
#   # region             = var.region
#   # discvm_count       = var.discvm_count
#   # backendvm_count    = var.backendvm_count
#   region             = each.key
#   backendvm_count    = each.value.backendvm_count
#   discvm_count       = each.value.discvm_count
#   disc_instance_type = var.disc_instance_type
#   be_instance_type   = var.be_instance_type
#   pgsql_password     = var.pgsql_password
#   admin_password     = var.admin_password
#   userA_password     = var.userA_password
#   userB_password     = var.userB_password
# }

module "aws_resources_for_region1" {
  count     = var.cloud == "AWS" ? 1 : 0
  source    = "./AWS"
  providers = { aws = aws.region1 }
  cloud              = var.cloud
  region             = var.region1
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
  count     = var.cloud == "AWS" ? 1 : 0
  source    = "./AWS"
  providers = { aws = aws.region2 }
  cloud              = var.cloud
  region             = var.region2
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