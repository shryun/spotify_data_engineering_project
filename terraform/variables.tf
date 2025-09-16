variable "account_id" {
  type        = string
  description = "Account Id AWS"
  default     = "216989135823"
}

variable "region" {
  type        = string
  description = "Region AWS"
  default     = "us-east-1"
}

variable "lambda_function_name" {
  type        = string
  description = "Lambda function name"
  default     = "spotify_data_pipeline_lambda"
}

variable "pipeline_name" {
  type        = string
  description = "Name of pipeline"
  default     = "pipeline-spotify-data"
}