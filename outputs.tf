output "public_ip" {
  description = "Public IP address of the deployed EC2 server"
  value       = aws_instance.web_server.public_ip
}
