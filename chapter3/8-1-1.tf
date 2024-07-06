variable "env" {
  description = "Environment Name"
  type        = string

  validation {
    condition     = contains(["development", "rc", "production"], var.env)
    error_message = "Env는 반드시 [development, rc, production] 중 하나여야 합니다."
  }
}
