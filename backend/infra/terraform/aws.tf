provider "aws" {
  region = "us-west-1"  # Adjust
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service =  ["lambda.amazonaws.com", "states.amazonaws.com"]}
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "logs:*"
      Effect = "Allow"
      Resource = "*"
    },
     {
      Action = "lambda:InvokeFunction"
      Effect = "Allow"
      Resource = aws_lambda_function.redis_counter.arn
     }
     ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "redis_counter" {
  filename      = "../../node/common/function.zip" #the hitter code
  function_name = "redis_counter"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  environment {
    variables = {
      API_URL = aws_api_gateway_deployment.redis_api.invoke_url
    }
  }
 depends_on = [aws_api_gateway_deployment.redis_api]
}

resource "aws_sfn_state_machine" "counter_game" {
  name     = "redis_counter_game"
  role_arn = aws_iam_role.lambda_exec.arn
  definition = <<EOF
  {
    "StartAt": "PushCounter",
    "States": {
      "PushCounter": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.redis_counter.arn}",
        "ResultPath": "$.result",
        "Next": "Wait"
      },
      "Wait": {
        "Type": "Wait",
        "Seconds": 45,
        "Next": "CheckTime"
      },
      "CheckTime": {
        "Type": "Choice",
        "Choices": [
          {
            "Variable": "$.time",
            "NumericLessThan": 600,
            "Next": "PushCounter"
          }
        ],
        "Default": "Done"
      },
      "Done": {
        "Type": "Succeed"
      }
    }
  }
  EOF
}
