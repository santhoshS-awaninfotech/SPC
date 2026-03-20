# output "backend_public_ips" {
#   value = aws_eip.back_pip[*].public_ip
# }

# output "discovery_public_ips" {
#   value = aws_eip.disc_pip[*].public_ip
# }

output "backend_ip_map" {
  value = {
    for idx, eip in aws_eip.back_pip :
    idx => {
      ip            = eip.public_ip
      region        = provider.aws.region
      instance_name = aws_instance.backVM[idx].tags["Name"]
      resource_name = "aws_eip.back_pip[${idx}]"
    }
  }
}

output "discovery_ip_map" {
  value = {
    for idx, eip in aws_eip.disc_pip :
    idx => {
      ip            = eip.public_ip
      region        = provider.aws.region
      instance_name = aws_instance.discVM[idx].tags["Name"]
      resource_name = "aws_eip.disc_pip[${idx}]"
    }
  }
}