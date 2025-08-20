variable "host_os" {
  type    = string
  default = "linux" # or "windows"
}

variable "sp_object_id" {
  description = "Object (principal) ID of the GitHub OIDC Service Principal"
  type        = string
}

variable "admin_ssh_pubkey" {
  description = "SSH public key for the VM admin user"
  type        = string
}
