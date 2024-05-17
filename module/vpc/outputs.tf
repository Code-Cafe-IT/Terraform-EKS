output "vpc_id" {
  value = aws_vpc.cmc_vpc.id
}
output "public_subnet_1a" {
  value = aws_subnet.cmc_public_subnet_1a.id
}
output "public_subnet_1b" {
  value = aws_subnet.cmc_public_subnet_1b.id
}
output "private_subnet_1a" {
  value = aws_subnet.cmc_private_subnet_1a.id
}
output "private_subnet_1b" {
  value = aws_subnet.cmc_private_subnet_1b.id
}

