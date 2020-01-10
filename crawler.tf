resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  count = length(var.glue_crawler) == 0 ? 0 : 1
  name  = var.glue_crawler["database_name"]
}

resource "aws_glue_crawler" "crawler" {
  count         = length(var.glue_crawler) == 0 ? 0 : 1
  configuration = <<CONFIGURATION
  {
   "Version": 1.0,
   "CrawlerOutput": {
    "Partitions": {
      "AddOrUpdateBehavior": "InheritFromTable"
    },
    "Tables": {
      "AddOrUpdateBehavior": "MergeNewColumns"
    }
   }
  }
  
CONFIGURATION
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.0.name
  description   = var.glue_crawler["description"] == null ? "Crawler for ${aws_dynamodb_table.table.name}" : var.glue_crawler["description"]

  dynamodb_target {
    path = aws_dynamodb_table.table.name
  }

  name     = var.name
  schedule = var.glue_crawler["schedule"]
  role     = aws_iam_role.crawler.0.arn
}

resource "aws_iam_role" "crawler" {
  count              = length(var.glue_crawler) == 0 ? 0 : 1
  assume_role_policy = data.aws_iam_policy_document.aws_glue_assume_role.json
  name               = "${var.name}-table-crawler"
}

resource "aws_iam_role_policy_attachment" "crawler_glue" {
  count      = length(var.glue_crawler) == 0 ? 0 : 1
  role       = aws_iam_role.crawler.0.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "crawler_dynamo" {
  count  = length(var.glue_crawler) == 0 ? 0 : 1
  name   = "${var.name}-table-crawler"
  policy = data.aws_iam_policy_document.aws_glue_crawler_dynamo_access.json
}

resource "aws_iam_role_policy_attachment" "crawler_dynamo" {
  count      = length(var.glue_crawler) == 0 ? 0 : 1
  role       = aws_iam_role.crawler.0.id
  policy_arn = aws_iam_policy.crawler_dynamo.0.arn
}