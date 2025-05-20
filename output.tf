output "vpc_id" {
  description = "vpc id is"
  value       = aws_vpc.vpc.id

}
output "sg_id" {
  description = "sg id is"
  value       = aws_security_group.jenkins_sg.id

}
output "public_subnet_id" {
  description = "public subnet id is"
  value       = aws_subnet.public_subnet.id

}
output "jenkins_eip" {
  description = "jenkins elastic public ip is"
  value       = aws_eip.eip.public_ip

}