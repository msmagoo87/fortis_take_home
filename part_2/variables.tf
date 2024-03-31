variable "bastion_instance_type" {
  type        = string
  description = "The instance type to make the bastion host. Default is t2.micro."
  default     = "t2.micro"
}

variable "web_server_instance_type" {
  type        = string
  description = "The instance type to make the web server. Default is t2.micro."
  default     = "t2.micro"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to the resources."
  default = {
    managed-by = "Terraform"
  }
}

variable "domain_name" {
  type        = string
  description = "The full domain name to use. Ex. mywebpage.fortis-games.com"
}

variable "zone_id" {
  type        = string
  description = "The ID of the route53 zone."
}

variable "bastion_access_cidr" {
  type        = list(string)
  description = "A list of cidr blocks that are allowed to access the bastion host."
}