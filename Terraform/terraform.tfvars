
vpc_cidr            = "10.100.0.0/22"
backsubnet_cidr     = "10.100.1.0/24"
discsubnet_cidr     = "10.100.2.0/24"
disc_instance_type  = "t3.micro"
be_instance_type    = "t3.micro"

region1                 = "ap-south-1"
region2                 = "us-east-1"
reg1_code               = "MUM"
reg2_code               = "NVA"
backendvm_count_region1 = 1
discvm_count_region1    = 0
backendvm_count_region2 = 1
discvm_count_region2    = 1