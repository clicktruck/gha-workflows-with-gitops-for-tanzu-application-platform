# Terraform a new AWS RDS Postgres instance

Based on the following Terraform [example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone#example-usage).



```hcl
module "rds" {
  source = "git::https://gitlab.com/guardianproject-ops/terraform-aws-rds-postgresql?ref=master"

  engine               = "postgres"
  instance_class       = var.instance_class
  engine_version       = "12.4"
  major_engine_version = "12.4"
  family               = "postgres12"
  allocated_storage    = var.allocated_storage

  # rds meta
  deletion_protection_enabled = var.is_prod_like
  apply_immediately           = var.is_prod_like
  skip_final_snapshot         = true
  allow_major_version_upgrade = false
  backup_retention_period     = var.backup_retention_period

  # network
  vpc_id         = var.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
  subnet_ids     = var.subnet_ids

  database_name     = var.admin_database_name
  database_username = var.admin_database_username
  database_password = var.admin_database_password

  context = module.this.context
}

```






## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| allocated\_storage | n/a | `number` | n/a | yes |
| allow\_major\_version\_upgrade | n/a | `bool` | n/a | yes |
| apply\_immediately | n/a | `bool` | n/a | yes |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| backup\_retention\_period | n/a | `number` | n/a | yes |
| backup\_window | n/a | `string` | `"03:00-06:00"` | no |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| database\_name | n/a | `string` | n/a | yes |
| database\_password | n/a | `string` | n/a | yes |
| database\_username | n/a | `string` | n/a | yes |
| deletion\_protection\_enabled | n/a | `bool` | n/a | yes |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | n/a | yes |
| enabled | Set to false to prevent the module from creating any resources | `bool` | n/a | yes |
| engine | n/a | `string` | n/a | yes |
| engine\_version | n/a | `string` | n/a | yes |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | n/a | yes |
| family | n/a | `string` | n/a | yes |
| id\_length\_limit | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | n/a | yes |
| instance\_class | n/a | `string` | n/a | yes |
| kms\_key\_id | An optional KMS key to use to encrypt the database, if not provided, one will be generated. | `string` | `""` | no |
| kms\_key\_policy | A valid policy JSON document to be appplied to the kms key created by this module. Not necessary if supplying your own kms key. | `string` | `""` | no |
| label\_key\_case | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | n/a | yes |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | n/a | yes |
| label\_value\_case | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | n/a | yes |
| maintenance\_window | n/a | `string` | `"Mon:00:00-Mon:03:00"` | no |
| major\_engine\_version | n/a | `string` | n/a | yes |
| monitoring\_interval | n/a | `string` | `"60"` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | n/a | yes |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | n/a | yes |
| region\_settings\_params\_enabled | When enabled the connection information (except password) is stored in SSM Param Store region settings for this deployment | `bool` | `true` | no |
| skip\_final\_snapshot | n/a | `bool` | n/a | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | n/a | yes |
| subnet\_ids | n/a | `list(string)` | n/a | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| vpc\_cidr\_block | n/a | `string` | n/a | yes |
| vpc\_id | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| this\_db\_instance\_address | The address/hostname of the RDS instance |
| this\_db\_instance\_arn | The ARN of the RDS instance |
| this\_db\_instance\_availability\_zone | The availability zone of the RDS instance |
| this\_db\_instance\_endpoint | The connection endpoint |
| this\_db\_instance\_hosted\_zone\_id | The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record) |
| this\_db\_instance\_id | The RDS instance ID |
| this\_db\_instance\_name | The database name |
| this\_db\_instance\_password | The database password (this password may be old, because Terraform doesn't track it after initial creation) |
| this\_db\_instance\_port | The database port |
| this\_db\_instance\_resource\_id | The RDS Resource ID of this instance |
| this\_db\_instance\_status | The RDS instance status |
| this\_db\_instance\_username | The master username for the database |
| this\_db\_parameter\_group\_arn | The ARN of the db parameter group |
| this\_db\_parameter\_group\_id | The db parameter group id |
| this\_db\_subnet\_group\_arn | The ARN of the db subnet group |
| this\_db\_subnet\_group\_id | The db subnet group name |
