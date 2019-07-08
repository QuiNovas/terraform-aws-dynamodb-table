locals {
  global_secondary_indexes_count = length(var.global_secondary_index)
  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
  )
}

