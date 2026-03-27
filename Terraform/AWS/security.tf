# Security Group
resource "aws_security_group" "backend_sg" {
  name   = "SG-${var.reg_code}-SPC-STG-UIDB"
  vpc_id = aws_vpc.spcvpc.id
  tags   = merge(var.common_tags, { Name = "SG-${var.reg_code}-SPC-STG-UIDB"})

  ingress {
    Name        = "TestName"
    description = "Allow RDP from anywhere"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "Allow Postgres from VPC and public"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.100.2.0/24", "0.0.0.0/0"] 
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "discovery_sg" {
  name   = "SG-${var.reg_code}-SPC-STG-RUNR"
  vpc_id = aws_vpc.spcvpc.id
  tags   = merge(var.common_tags, { Name = "SG-${var.reg_code}-SPC-STG-RUNR"})

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}