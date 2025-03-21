resource "aws_lambda_function" "redis_api" {
  filename      = "../../node/api.zip"
  function_name = "redis-api"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "api.handler"
  runtime       = "nodejs18.x"
  source_code_hash = filebase64sha256("../../node/api.zip")
  environment  {
      variables = local.envs #REDIS_HOST, REDIS_PORT...
  }
}

resource "aws_api_gateway_rest_api" "redis_api" {
  name        = "RedisAPI"
  description = "API for Redis scores"
}

resource "aws_api_gateway_api_key" "redis_api_key" {
  name = "redis-api-key"
}

resource "aws_api_gateway_usage_plan" "redis_api_plan" {
  name = "redis-api-usage"
  api_stages {
    api_id = aws_api_gateway_rest_api.redis_api.id
    stage  = aws_api_gateway_deployment.redis_api.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "redis_api_key_plan" {
  key_id       = aws_api_gateway_api_key.redis_api_key.id
  key_type     = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.redis_api_plan.id
}

resource "aws_api_gateway_resource" "scores" {
  rest_api_id = aws_api_gateway_rest_api.redis_api.id
  parent_id   = aws_api_gateway_rest_api.redis_api.root_resource_id
  path_part   = "scores"
}

resource "aws_api_gateway_resource" "hit" {
  rest_api_id = aws_api_gateway_rest_api.redis_api.id
  parent_id   = aws_api_gateway_rest_api.redis_api.root_resource_id
  path_part   = "hit"
}

resource "aws_api_gateway_method" "scores_get" {
  rest_api_id   = aws_api_gateway_rest_api.redis_api.id
  resource_id   = aws_api_gateway_resource.scores.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method" "hit_post" {
  rest_api_id   = aws_api_gateway_rest_api.redis_api.id
  resource_id   = aws_api_gateway_resource.hit.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "scores_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.redis_api.id
  resource_id             = aws_api_gateway_resource.scores.id
  http_method             = aws_api_gateway_method.scores_get.http_method
  integration_http_method = "POST"  # Lambda—proxy
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.redis_api.invoke_arn
}

resource "aws_api_gateway_integration" "hit_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.redis_api.id
  resource_id             = aws_api_gateway_resource.hit.id
  http_method             = aws_api_gateway_method.hit_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.redis_api.invoke_arn
}

resource "aws_api_gateway_deployment" "redis_api" {
  depends_on = [
    aws_api_gateway_integration.scores_lambda,
    aws_api_gateway_integration.hit_lambda
  ]
  rest_api_id = aws_api_gateway_rest_api.redis_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redis_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.redis_api.execution_arn}/*/*"
}
resource "local_file" "docker_env" {
  content = <<EOF
API_URL=${aws_api_gateway_deployment.redis_api.invoke_url}
EOF
filename = "${path.cwd}/docker.env"
depends_on = [aws_api_gateway_deployment.redis_api]
}

output "env_variables" {
  value = {
    redis_host     = try(local.envs["REDIS_HOST"], "not_set")
    redis_port     = try(local.envs["REDIS_PORT"], "6379")
    redis_password = try(local.envs["REDIS_PASSWORD"], "not_set")
    API_URL        = aws_api_gateway_deployment.redis_api.invoke_url
  }
}
output "api_url" {
  value = aws_api_gateway_deployment.redis_api.invoke_url
}
