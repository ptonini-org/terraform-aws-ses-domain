variable "domain" {}

variable "zone_id" {
  default = null
}

variable "email_identities" {
  type    = set(string)
  default = []
}
