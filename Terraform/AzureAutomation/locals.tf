# Defining local variables for use in the Terraform configuration

locals {
  time_zone = "Europe/Paris"
  time_of_day = "00:00:00+02:00"
  now = timestamp()
  tomorrow = timeadd(timestamp(), "48h")
  tomorrow_date = substr(local.tomorrow, 0, 11)
  midnight = "${local.tomorrow_date}${local.time_of_day}"
  expiry_time = "9999-12-31T23:59:59+02:00"
  location = "westeurope"
}