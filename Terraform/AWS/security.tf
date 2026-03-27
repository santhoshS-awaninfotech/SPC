# Security Group
resource "aws_security_group" "backend_sg" {
  name   = "SG-${var.reg_code}-SPC-STG-UIDB"
  vpc_id = aws_vpc.spcvpc.id
  tags   = merge(var.common_tags, { Name = "SG-${var.reg_code}-SPC-STG-UIDB"})
}
resource "aws_vpc_security_group_ingress_rule" "rdp_ingress_fe" {
  security_group_id = aws_security_group.backend_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3389
  to_port           = 3389
  ip_protocol       = "tcp"
  description       = "Allow RDP from anywhere"
  tags              = { Name = "UIDB_RDP Rule" }

}
 resource "aws_vpc_security_group_ingress_rule" "postgres_ingress_fe" {
  security_group_id = aws_security_group.backend_sg.id
  cidr_ipv4         = "10.100.2.0/24"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  description       = "Allow Postgres from VPC"
  tags              = { Name = "UIDB_Postgres Rule" }

}
resource "aws_vpc_security_group_egress_rule" "all_outbound_fe" {
  security_group_id = aws_security_group.backend_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
  tags              = { Name = "UIDB_OutboundRule" }

}



resource "aws_security_group" "discovery_sg" {
  name   = "SG-${var.reg_code}-SPC-STG-RUNR"
  vpc_id = aws_vpc.spcvpc.id
  tags   = merge(var.common_tags, { Name = "SG-${var.reg_code}-SPC-STG-RUNR"})

}

resource "aws_vpc_security_group_ingress_rule" "rdp_ingress_be" {
  security_group_id = aws_security_group.discovery_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3389
  to_port           = 3389
  ip_protocol       = "tcp"
  description       = "Allow RDP from anywhere"
  tags              = { Name = "Runner_RDPRule" }

}

resource "aws_vpc_security_group_egress_rule" "all_outbound_be" {
  security_group_id = aws_security_group.discovery_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
  tags              = { Name = "Runner_OutboundRule" }

}