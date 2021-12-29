variable "region"{
  description = "project region"
  default = "ap-northeast-2"
}

variable "tag" {
  description = "tag name"
}
variable "vpc_name" {
  description = "VPC name"
}

variable "cidr" {
  default = "vpc cidr"
}

variable "cidr_public" {
  default = {
      "0" = "1"
      "1" = "2"
  }
}

variable "cidr_privatec" {
  default = {
      "0" = "3"
      "1" = "4"
      "2" = "5"
  }
}

variable "cidr_privated" {
  default = {
      "0" = "6"
      "1" = "7"
      "2" = "8"
  }
}

variable "az" {
  type = list(string)
  description = "Availability Zones"
}

variable "sg"{
  default = [ "exelb", "web", "inelb", "was", "db"]
}