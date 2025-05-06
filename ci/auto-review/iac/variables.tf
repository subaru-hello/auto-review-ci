###############################################################################
# variables.tf
###############################################################################
variable "project_name"        { default = "auto-code-review" }
variable "github_owner"        { type = string }          # ex) my-org
variable "github_repo"         { type = string }          # ex) my-repo
variable "codestar_connection" { type = string }          # AWS Console で作った GitHub コネクション ARN
variable "region"              { default = "ap-northeast-1" }
