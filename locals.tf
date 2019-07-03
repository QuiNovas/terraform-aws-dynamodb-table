locals {
  global_secondary_indexes_count = var.global_secondary_indexes_count
  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
  )
}

