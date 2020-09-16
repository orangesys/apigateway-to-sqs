resource "aws_sqs_queue" "queue" {
  name                      = var.queue_name
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = var.queue_tags
}

resource "aws_iam_role" "apiSQS" {
  name               = var.apigateway_rolename
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "template_file" "gateway_policy" {
  template = file("./policies/api-gateway-permission.json")

  vars = {
    sqs_arn = aws_sqs_queue.queue.arn
  }
}

resource "aws_iam_policy" "api_policy" {
  name = "api-sqs-cloudwatch-policy"

  policy = data.template_file.gateway_policy.rendered
}

resource "aws_iam_role_policy_attachment" "api_exec_role" {
  role       = aws_iam_role.apiSQS.name
  policy_arn = aws_iam_policy.api_policy.arn
}

data "template_file" "_" {
  template = var.api_template

  vars = {
    api_arn = aws_iam_role.apiSQS.arn
    sqs_arn = aws_sqs_queue.queue.arn
  }

  # vars = var.api_template_vars
}

resource "aws_api_gateway_rest_api" "apiGateway" {
  name               = var.api_name
  api_key_source     = "HEADER"
  binary_media_types = var.binary_media_types
  description        = var.api_description

  body = data.template_file._.rendered

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.apiGateway.id
  stage_name  = var.stage_name

  triggers = {
    redeployment = sha1(data.template_file._.rendered)
  }

  lifecycle {
    create_before_destroy = true
  }
}

