variable "attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes."
  type        = "list"
}

variable "autoscaling_service_role_arn" {
  description = "The ARN of the IAM role that allows Application AutoScaling to modify your scalable target on your behalf."
  type        = "string"
}

variable "billing_mode" {
  default     = "PROVISIONED"
  description = "Controls how you are charged for read and write throughput and how you manage capacity. The valid values are PROVISIONED and PAY_PER_REQUEST."
  type        = "string"
}

variable "global_secondary_indexes" {
  default     = []
  description = "Describe a GSO for the table; subject to the normal limits on the number of GSIs, projected attributes, etc."
  type        = "list"
}

variable "global_secondary_indexes_count" {
  default     = 0
  description = "The number of GSIs"
  type        = "string"
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key. Must also be defined as an attribute, see below."
  type        = "string"
}

variable "local_secondary_indexes" {
  default     = []
  description = "Describe an LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource."
  type        = "list"
}

variable "name" {
  description = "The name of the table, this needs to be unique within a region."
  type        = "string"
}

variable "read_capacity" {
  default     = {
    max = 1
    min = 1
  }
  description = "The number of read units for this table, expressed as min and max."
  type        = "map"
}

variable "range_key" {
  default     = ""
  description = "The attribute to use as the range (sort) key. Must also be defined as an attribute, see below."
  type        = "string"
}

variable "stream_view_type" {
  default     = ""
  description = "When an item in the table is modified, StreamViewType determines what information is written to the table's stream. Valid values are KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  type        = "string"
}

variable "tags" {
  default     = {}
  description = "A map of tags to populate on the created table."
  type        = "map"
}

variable "ttl_attribute_name" {
  default     = ""
  description = "The name of the table attribute to store the TTL timestamp in."
  type        = "string"
}

variable "write_capacity" {
  default     = {
    max = 1
    min = 1
  }
  description = "The number of write units for this table, expressed as min and max."
  type        = "map"
}