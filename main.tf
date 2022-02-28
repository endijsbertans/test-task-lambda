resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "nuTevJastrada" {
  name = "nuTevJastradaBlin"
  role = aws_iam_role.iam_for_lambda.id
  policy = file("ec2_policy.json")
}
# resource "aws_lambda_layer_version" "lambda_layer" {
#   filename   = "python.zip"
#   layer_name = "terraLayer"

#   compatible_runtimes = ["python3.9"]
# }

resource "aws_lambda_function" "test_lambda" {
  depends_on = [
    aws_security_group.lb_sg
  ]

  filename      = "lambda_function.zip"
  function_name = "testLambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  runtime          = "python3.9"
  timeout          = "30"
  memory_size      = 256
  publish          = true

  
  vpc_config {
    # subnet-028177bc4b27450dc, subnet-0591ab2bf707ce98c
    subnet_ids = tolist(["subnet-028177bc4b27450dc", "subnet-0591ab2bf707ce98c"])
    security_group_ids = [aws_security_group.lb_sg.id]
  }




#   layers = [aws_lambda_layer_version.lambda_layer.arn]

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("lambda_function.zip")


  environment {
    variables = {
      foo = "bar"
    }
  }
}

