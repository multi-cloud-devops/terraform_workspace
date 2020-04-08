provider "alicloud" {

  region = var.region
  profile =  var.profile
  version              = ">=1.56.0"
  configuration_source = "terraform-alicloud-modules/classic-load-balance"

}