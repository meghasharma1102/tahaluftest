variable "management_group_id" {
  description = "Full resource ID of the management group where definitions are created"
  type        = string
}

variable "management_group_name" {
  description = "Short name of the management group (e.g. 'myorg') - used to replace 'contoso' in ALZ JSONs"
  type        = string
}