# Security Group
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.spcvpc.id
  tags   = merge(var.common_tags, { Name = "SG-SPC-FOR-BE" })

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.100.2.0/24", "0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "discovery_sg" {
  vpc_id = aws_vpc.spcvpc.id
  tags   = merge(var.common_tags, { Name = "SG-SPC-FOR-DISC" })

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