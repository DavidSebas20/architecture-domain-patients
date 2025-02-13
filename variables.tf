variable "BRANCH_NAME" {
  description = "Nombre de la rama para las imágenes de Docker"
  type        = string
}

variable "DB_URL" {
  description = "URL de la base de datos"
  type        = string
}

variable "DB_USERNAME" {
  description = "Nombre de usuario de la base de datos"
  type        = string
}

variable "DB_PASSWORD" {
  description = "Contraseña de la base de datos"
  type        = string
}

variable "HASH_SERVICE_URL" {
  description = "URL del servicio de hash"
  type        = string
}

variable "VERIFY_SERVICE_URL" {
  description = "URL del servicio de verificación"
  type        = string
}

variable "PORT_CREATE_PATIENT" {
  description = "Puerto para el servicio de creación de pacientes"
  type        = string
  default     = "6000"
}

variable "PORT_READ_PATIENT" {
  description = "Puerto para el servicio de lectura de pacientes"
  type        = string
  default     = "6001"
}

variable "PORT_UPDATE_PATIENT" {
  description = "Puerto para el servicio de actualización de pacientes"
  type        = string
  default     = "6002"
}

variable "PORT_DELETE_PATIENT" {
  description = "Puerto para el servicio de eliminación de pacientes"
  type        = string
  default     = "6003"
}

variable "AWS_REGION" {
  description = "Región de AWS"
  type        = string
}

variable "AWS_ACCESS_KEY_ID" {
  description = "ID de acceso de AWS"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "Clave secreta de AWS"
  type        = string
}

variable "AWS_SESSION_TOKEN" {
  description = "Token de sesión de AWS"
  type        = string
}