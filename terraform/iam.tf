# create an IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
    name = "lambda-execution-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole",
                Principal = {
                    Service = "lambda.amazonaws.com"
                },
                Effect = "Allow"
            }
        ]
    })
}

# create an IAM policy for Lambda
resource "aws_iam_policy" "lambda_policy" {
    name        = "lambda-policy"

    policy      = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "s3:*"
                ],
                Effect = "Allow",
                Resource = "*"
            },
            {
                Action = [
                    "athena:*"
                ],
                Effect = "Allow",
                Resource = "*"
            },
            {
                Action = [
                    "logs:CreateLogGroup", # create a cloudwatch log group
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                Effect = "Allow",
                Resource = "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${var.lambda_function_name}:*"
            },
            {
                Action = [
                    "glue:*"
                ],
                Effect = "Allow",
                Resource = "*"
            },
            {
                Action = [
                  "secretsmanager:GetSecretValue",
                  "secretsmanager:DescribeSecret"
                ],
                Effect = "Allow",
                Resource = "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:spotify-api-credentials-*"
            }
        ]
    })
} 

# attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}



# create an IAM role for glue
resource "aws_iam_role" "glue_service_role" {
  name = "glue_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# create an IAM policy for glue
resource "aws_iam_policy" "glue_service_role_policy" {
  name        = "glue_policy"
  description = "Policy for Glue Role to access S3 scripts bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*"
        ]
        Effect = "Allow"
        Resource = [
          "*" # Replace with S3 scripts bucket ARN
        ]
      },
      {
        Action = [
          "glue:*"
        ],
        Effect   = "Allow",
        Resource = ["*"]
      },
      {
        Action = [
          "cloudwatch:*"
        ]
        Effect   = "Allow",
        Resource = ["*"]
      },
      {
        Action = [
          "logs:*"
        ],
        Effect   = "Allow",
        Resource = ["*"]
      }
    ]
  })
}

# attach the policy to the glue role
resource "aws_iam_role_policy_attachment" "glue_role_policy_attachment" {
  role       = aws_iam_role.glue_service_role.id
  policy_arn = aws_iam_policy.glue_service_role_policy.arn
}

# create an IAM role for codebuild
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-deploy-pipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# create an IAM policy for codebuild
resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-deploy-pipeline-weather-data-policy"
  description = "Policy for CodeBuild to deploy Lambda and Glue for pipeline-weather-data"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:*",
          "glue:*",
          "iam:PassRole",
          "iam:CreateRole",
          "iam:GetRole",
          "iam:DeleteRolePolicy",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "s3:*" # Example - Refine as needed
        ],
        Resource = "*" # Refine resources for security best practices
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = aws_iam_role.lambda_role.arn
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = aws_iam_role.glue_service_role.arn
      }
    ]
  })
}

# attach the policy to the codebuild role
resource "aws_iam_policy_attachment" "codebuild_policy_attach" {
  name       = "codebuild-policy-attachment"
  policy_arn = aws_iam_policy.codebuild_policy.arn
  roles      = [aws_iam_role.codebuild_role.name]
}