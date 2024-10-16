#########################################################################################################
## Terraform configurations (AWS)
#########################################################################################################
#variable "aws_access_key" {
#  type        = string
#  description = "AWS Access Key"
#}
#
#variable "aws_secret_key" {
#  type        = string
#  description = "AWS Secret Key"
#}
#
#variable "aws_session_token" {
#  type        = string
#  description = "AWS Session Token"
#}

variable "pem_location" {
  type    = string
  default = "."
}

variable "terraform_aws_profile" {
  type = string
  default = "jaebin"
}

variable "terraform_workspace-name" {
  type = string
  default = "jaebin"
}

variable "aws_region" {
  type = string
  default = "ap-northeast-2"
}

variable "cluster-name" {
  default = "cluster"
}

variable "cluster-version" {
  default = "1.30"
}

locals {
    region = "ap-northeast-2"
}