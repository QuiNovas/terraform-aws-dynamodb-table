output "arn" {
  description = "The arn of the table"
  value       = "${aws_dynamodb_table.table.arn}"
}

output "hash_key" {
  description = "The attribute to use as the hash (partition) key."
  value       = "${aws_dynamodb_table.table.hash_key}"
}

output "name" {
  description = "The name of the table."
  value       = "${aws_dynamodb_table.table.name}"
}

output "stream_arn" {
  description = "The ARN of the Table Stream. Only available if stream_view_type is set."
  value       = "${aws_dynamodb_table.table.stream_enabled == true ? aws_dynamodb_table.table.stream_arn : ""}"
}