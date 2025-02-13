output "load_balancer_dns" {
  description = "DNS público del Load Balancer para realizar peticiones"
  value       = aws_lb.patient_alb.dns_name
}

output "load_balancer_arn" {
  description = "ARN del Load Balancer"
  value       = aws_lb.patient_alb.arn
}

# Mostrar la clave privada SSH generada
output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}