variable "aws_region" {
    description = "The AWS region to create things in."
    type        = string
    default     = "eu-west-1"
}

variable "tag_name" {
    description = "Value of the tag for the EC2 instance that should be scheduled"
    type        = string
    default     = "schedule required"
}

variable "stop_time" {
    description = "Cronlike Schedule for stop"
    type        = string
    default     = "0 17 ? * 2-6 *"
}

variable "start_time" {
    description = "Cronlike Schedule for start"
    type        = string
    default     = "0 8 ? * 2-6 *"
}