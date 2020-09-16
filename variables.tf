variable "queue_name" {
  description = "queue name"
  type        = string
}

variable "queue_tags" {
  type    = map
  default = {}
}

variable "apigateway_rolename" {
  type    = string
  default = "apigateway_sqs"
}

variable "api_name" {
  type    = string
  default = "api-gateway-SQS"
}

variable "api_template" {
  description = "API Gateway OpenAPI 3 template file"
}

variable "binary_media_types" {
  description = "Binary Media Types"
  type        = list
}

variable "api_description" {
  description = "The description of the REST API"
  type        = string
  default     = ""
}
