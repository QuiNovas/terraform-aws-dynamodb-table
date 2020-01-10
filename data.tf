data "aws_iam_policy_document" "aws_glue_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["glue.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "aws_glue_crawler_dynamo_access" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:Scan"
    ]

    resources = [
      aws_dynamodb_table.table.arn
    ]

  }
}