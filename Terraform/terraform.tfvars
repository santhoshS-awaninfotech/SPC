
vpc_cidr            = "10.100.0.0/22"
backsubnet_cidr     = "10.100.1.0/24"
discsubnet_cidr     = "10.100.2.0/24"
region2              = "east-us-1"
region1              = "ap-south-1"
disc_instance_type  = "t3.micro"
be_instance_type    = "t3.micro"
regions = {
  "ap-south-1" = {
    backendvm_count = 2
    discvm_count    = 1
  }
  "us-west-2" = {
    backendvm_count = 0
    discvm_count    = 2
  }
}