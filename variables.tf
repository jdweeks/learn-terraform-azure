variable "resource_group" {
  type = string
}

variable "admin_username" {
  type        = string
  description = "Administrator user name for virtual machine"
}

variable "prefix" {
  type    = string
  default = "my"
}

variable "tags" {
  type = map(any)

  default = {
    Environment = "Terraform GS"
    Dept        = "Engineering"
  }
}

variable "vm_sku" {
  default = {
    westus2 = "16.04-LTS"
    eastus  = "18.04-LTS"
    centralus  = "18.04-LTS"
  }
}
