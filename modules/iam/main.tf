resource "aws_iam_role" "lambda_role" {

  name = "cloudbox-lambda-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "lambda.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {

  role = aws_iam_role.lambda_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

}

resource "aws_iam_policy" "dynamodb_policy" {

  name = "cloudbox-dynamodb-policy"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Action = [

          "dynamodb:GetItem",

          "dynamodb:PutItem",

          "dynamodb:UpdateItem",

          "dynamodb:DeleteItem",

          "dynamodb:Scan",

          "dynamodb:Query"

        ]

        Resource = "*"

      }

    ]

  })

}

resource "aws_iam_role_policy_attachment" "dynamodb_attachment" {

  role = aws_iam_role.lambda_role.name

  policy_arn = aws_iam_policy.dynamodb_policy.arn



}

resource "aws_iam_role_policy" "producer_sqs_policy" {
  name = "producer-sqs-policy"

  role = aws_iam_role.lambda_role.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [{

      Effect = "Allow"
      Action = ["sqs:SendMessage"]

      Resource = "arn:aws:sqs:*:*:documents-queue*"

      }

    ]

  })

}
resource "aws_iam_role_policy" "consumer_sqs_policy" {
  name = "consumer-sqs-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "arn:aws:sqs:*:*:documents-queue*"
      }
    ]
  })
}


resource "aws_iam_role_policy" "consumer_dynamodb_policy" {
  name = "consumer-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = "arn:aws:dynamodb:*:*:table/documents"
      }
    ]
  })
}
