variable "prefix" {
  type        = string
  description = "Resources name prefix"
  default     = "d01"
}

variable "resource_group_location" {
  type        = string
  description = "Location of the resource group."
  default     = "northeurope"
}
