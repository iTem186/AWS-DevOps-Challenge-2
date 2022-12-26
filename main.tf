terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.16"
        }
    }

    required_version = ">= 1.0.0"
}

provider "aws" {
    region = "${var.aws_region}"
}

provider "archive" {}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_file = "main.py"
    output_path = "main.zip"
}

resource "aws_instance" "AWS_DevOps_Challenge-2_VM1" {
    ami           = "ami-0f6bb954c3dbf0ba3"
    instance_type = "t2.micro"
  
    tags = {
        Name                = "AWS_DevOps_Challenge-2_VM1"
        "${var.tag_name}"   = "${var.tag_value}"
    }
}

resource "aws_instance" "AWS_DevOps_Challenge-2_VM2" {
    ami           = "ami-0f6bb954c3dbf0ba3"
    instance_type = "t2.micro"
  
    tags = {
        Name                = "AWS_DevOps_Challenge-2_VM2"
        "${var.tag_name}"   = "${var.tag_value}"
    }
}

resource "aws_instance" "AWS_DevOps_Challenge-2_VM3" {
    ami           = "ami-0f6bb954c3dbf0ba3"
    instance_type = "t2.micro"
  
    tags = {
        Name                = "AWS_DevOps_Challenge-2_VM3"
        "${var.tag_name}"   = "${var.tag_value}"
    }
}

resource "aws_iam_role" "iam_role_for_lambda" {
    name                = "iam_role_for_lambda"
    assume_role_policy  = "${file("iam_role_for_lambda.json")}"
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
  name   = "iam_policy_for_lambda"
  policy = "${file("iam_role_policy_for_lambda.json")}"
}

resource "aws_iam_policy_attachment" "iam_policy_attachment" {
    name       = "iam_policy_attachment"
    roles      = [aws_iam_role.iam_role_for_lambda.name]
    policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_lambda_function" "lambda_for_stop_instances" {
    function_name     = "lambda_for_stop_instances"
    filename          = data.archive_file.lambda_zip.output_path
    source_code_hash  = data.archive_file.lambda_zip.output_base64sha256
    role              = aws_iam_role.iam_role_for_lambda.arn
    handler           = "main.stop_instances"
    runtime           = "python3.9"

    environment {
        variables = {
            aws_region  = "${var.aws_region}",
            tag_name    = "${var.tag_name}",
            tag_value    = "${var.tag_value}"
        }
    }
}

resource "aws_lambda_function" "lambda_for_start_instances" {
    function_name     = "lambda_for_start_instances"
    filename          = data.archive_file.lambda_zip.output_path
    source_code_hash  = data.archive_file.lambda_zip.output_base64sha256
    role              = aws_iam_role.iam_role_for_lambda.arn
    handler           = "main.start_instances"
    runtime           = "python3.9"

    environment {
        variables = {
            aws_region  = "${var.aws_region}",
            tag_name    = "${var.tag_name}",
            tag_value    = "${var.tag_value}"
        }
    }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_stop_instances" {
    statement_id    = "AllowExecutionFromCloudWatch"
    action          = "lambda:InvokeFunction"
    function_name   = aws_lambda_function.lambda_for_stop_instances.function_name
    principal       = "events.amazonaws.com"
    source_arn      = aws_cloudwatch_event_rule.stop_timer.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_start_instances" {
    statement_id    = "AllowExecutionFromCloudWatch"
    action          = "lambda:InvokeFunction"
    function_name   = aws_lambda_function.lambda_for_start_instances.function_name
    principal       = "events.amazonaws.com"
    source_arn      = aws_cloudwatch_event_rule.start_timer.arn
}

resource "aws_cloudwatch_event_rule" "stop_timer" {
    name                  = "stop_timer"
    description           = "Cronlike scheduled Cloudwatch Event for stop instances"
    schedule_expression   = "cron(${var.stop_time})"
}

resource "aws_cloudwatch_event_rule" "start_timer" {
    name                  = "start_timer"
    description           = "Cronlike scheduled Cloudwatch Event for start instances"
    schedule_expression   = "cron(${var.start_time})"
}

resource "aws_cloudwatch_event_target" "run_lambda_for_stop_instances" {
    rule        = aws_cloudwatch_event_rule.stop_timer.name
    target_id   = aws_lambda_function.lambda_for_stop_instances.id
    arn         = aws_lambda_function.lambda_for_stop_instances.arn
}

resource "aws_cloudwatch_event_target" "run_lambda_for_start_instances" {
    rule        = aws_cloudwatch_event_rule.start_timer.name
    target_id   = aws_lambda_function.lambda_for_start_instances.id
    arn         = aws_lambda_function.lambda_for_start_instances.arn
}