resource "azuread_application" "k8s" {
  name                       = "${var.cluster_name}"
  homepage                   = "https://${var.cluster_name}"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "k8s" {
  application_id = "${azuread_application.k8s.application_id}"
}

resource "random_string" "password" {
  length = 16
  special = true
  override_special = "/@"
}

resource "azuread_service_principal_password" "k8s" {
  service_principal_id = "${azuread_service_principal.k8s.id}"
  value                = "${random_string.password.result}"
  end_date             = "${timeadd(timestamp(), "35040h")}"
}