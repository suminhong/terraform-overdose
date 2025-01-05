variable "environment" {
  type    = string
  default = "development"
}

variable "instance_count" {
  type    = number
  default = 3
}

variable "tags" {
  type = map(string)
  default = {
    "Owner" = "Sumin"
    "Team"  = "DevOps"
  }
}
