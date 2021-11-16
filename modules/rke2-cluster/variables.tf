variable "cluster_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "cloud" {
  type    = string
  default = "AzureUSGovernmentCloud"
  validation {
    condition     = contains(["AzureUSGovernmentCloud", "AzurePublicCloud"], var.cloud)
    error_message = "Allowed values for cloud are \"AzureUSGovernmentCloud\" or \"AzurePublicCloud\"."
  }
}

variable "vm_size" {
  type    = string
  default = "Standard_DS4_v2"
}

variable "server_vm_size" {
  type        = string
  description = "VM size to use for the server nodes"
  default     = ""
}

variable "agent_vm_size" {
  type        = string
  description = "VM size to use for the agent nodes"
  default     = ""
}

variable "server_instance_count" {
  type    = number
  default = 1
}

variable "agent_instance_count" {
  type    = number
  default = 2
}

variable "tags" {
  type    = object({})
  default = {}
}

variable "server_public_ip" {
  type    = bool
  default = false
}

variable "server_open_ssh_public" {
  type    = bool
  default = false
}
