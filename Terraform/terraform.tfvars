
vpc_cidr            = "10.100.0.0/16"
disc_instance_type  = "t3.micro"
be_instance_type    = "t3.micro"

region1                 = "ap-south-1"
region2                 = "us-east-1"
reg1_code               = "MUM"
reg2_code               = "NVA"
backendvm_count_region1 = 2
discvm_count_region1    = 2
backendvm_count_region2 = 0
discvm_count_region2    = 0