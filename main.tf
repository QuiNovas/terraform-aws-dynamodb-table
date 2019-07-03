resource "aws_dynamodb_table" "table" {
  dynamic "attribute" {
    for_each = [for attribute in var.attributes: {
      name = attribute.name
      type = attribute.type
    }]
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }
  billing_mode = var.billing_mode
  dynamic "global_secondary_index" {
    for_each = [for global_secondary_index in var.global_secondary_indexes:{
      hash_key           = global_secondary_index.hash_key
      name               = global_secondary_index.name
      non_key_attributes = global_secondary_index.non_key_attributes
      projection_type    = global_secondary_index.projection_type
      range_key          = global_secondary_index.range_key
      read_capacity      = global_secondary_index.read_capacity
      write_capacity     = global_secondary_index.write_capacity
    }]
    content {
      hash_key           = global_secondary_index.value.hash_key
      name               = global_secondary_index.value.name
      non_key_attributes = global_secondary_index.value.non_key_attributes
      projection_type    = global_secondary_index.value.projection_type
      range_key          = global_secondary_index.value.range_key
      read_capacity      = global_secondary_index.value.read_capacity
      write_capacity     = global_secondary_index.value.write_capacity
    }
  }
  hash_key = var.hash_key
  lifecycle {
    #Cannot list block type arguments inside this
    ignore_changes = [
      read_capacity,
      write_capacity,
      ttl
    ]
    prevent_destroy = true
  }
  dynamic "local_secondary_index" {
    for_each = [for local_secondary_index in var.local_secondary_indexes:{
      name               = local_secondary_index.name
      non_key_attributes = local_secondary_index.non_key_attributes
      projection_type    = local_secondary_index.projection_type
      range_key          = local_secondary_index.range_key
    }]
    content {
      name               = local_secondary_index.value.name
      non_key_attributes = local_secondary_index.value.non_key_attributes
      projection_type    = local_secondary_index.value.projection_type
      range_key          = local_secondary_index.value.range_key
    }
  }
  name          = var.name
  range_key     = var.range_key
  read_capacity = var.read_capacity["min"]
  server_side_encryption {
    enabled = true
  }
  stream_enabled   = length(var.stream_view_type) > 0 ? true : false
  stream_view_type = var.stream_view_type
  tags             = local.tags
  ttl {
    attribute_name = var.ttl_attribute_name
    enabled        = length(var.ttl_attribute_name) > 0 ? true : false
  }
  write_capacity = var.write_capacity["min"]
}

resource "aws_appautoscaling_target" "table_read" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  max_capacity       = var.read_capacity["max"]
  min_capacity       = var.read_capacity["min"]
  resource_id        = "table/${aws_dynamodb_table.table.name}"
  role_arn           = var.autoscaling_service_role_arn
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "table_read" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.table_read[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.table_read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_read[0].service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "table_write" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  max_capacity       = var.write_capacity["max"]
  min_capacity       = var.write_capacity["min"]
  resource_id        = "table/${aws_dynamodb_table.table.name}"
  role_arn           = var.autoscaling_service_role_arn
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "table_write" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.table_write[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.table_write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_write[0].service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "global_secondary_index_read" {
  count              = var.billing_mode == "PROVISIONED" ? local.global_secondary_indexes_count : 0
  max_capacity       = var.read_capacity["max"]
  min_capacity       = var.read_capacity["min"]
  resource_id        = "table/${aws_dynamodb_table.table.name}/index/${var.global_secondary_indexes[count.index]["name"]}"
  role_arn           = var.autoscaling_service_role_arn
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "global_secondary_index_read" {
  count              = var.billing_mode == "PROVISIONED" ? local.global_secondary_indexes_count : 0
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.global_secondary_index_read[count.index].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.global_secondary_index_read[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.global_secondary_index_read[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.global_secondary_index_read[count.index].service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "global_secondary_index_write" {
  count              = var.billing_mode == "PROVISIONED" ? local.global_secondary_indexes_count : 0
  max_capacity       = var.write_capacity["max"]
  min_capacity       = var.write_capacity["min"]
  resource_id        = "table/${aws_dynamodb_table.table.name}/index/${var.global_secondary_indexes[count.index]["name"]}"
  role_arn           = var.autoscaling_service_role_arn
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "global_secondary_index_write" {
  count              = var.billing_mode == "PROVISIONED" ? local.global_secondary_indexes_count : 0
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.global_secondary_index_write[count.index].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.global_secondary_index_write[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.global_secondary_index_write[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.global_secondary_index_write[count.index].service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = 70
  }
}

