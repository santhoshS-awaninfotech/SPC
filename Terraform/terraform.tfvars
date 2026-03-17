
vpc_cidr            = "10.100.0.0/22"
subnet_cidrs        = ["10.100.1.0/24", "10.100.2.0/24"]
backsubnet_cidr     = "10.100.1.0/24"
discsubnet_cidr     = "10.100.2.0/24"
region              = "ap-south-1"
discvm_count        = 2
backendvm_count     = 1
disc_instance_type  = "t3.micro"
be_instance_type    = "t3.micro"