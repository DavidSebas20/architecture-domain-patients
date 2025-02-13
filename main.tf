# Configuración del proveedor AWS
provider "aws" {
  region                   = var.AWS_REGION
  access_key               = var.AWS_ACCESS_KEY_ID
  secret_key               = var.AWS_SECRET_ACCESS_KEY
  token                    = var.AWS_SESSION_TOKEN
}

# Crear un par de claves SSH
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "patient-key-pair"
  public_key = tls_private_key.ssh_key.public_key_openssh
}