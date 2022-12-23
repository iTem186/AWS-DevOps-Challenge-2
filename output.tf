output "instance_public_ip_VM1" {
  description   = "Public IP address of the EC2 instance"
  value         = aws_instance.AWS_DevOps_Challenge-2_VM1.public_ip
}

output "instance_public_ip_VM2" {
  description   = "Public IP address of the EC2 instance"
  value         = aws_instance.AWS_DevOps_Challenge-2_VM2.public_ip
}

output "instance_public_ip_VM3" {
  description   = "Public IP address of the EC2 instance"
  value         = aws_instance.AWS_DevOps_Challenge-2_VM3.public_ip
}