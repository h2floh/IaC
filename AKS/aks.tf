resource "azurerm_resource_group" "k8s" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"
}

resource "azurerm_role_assignment" "test" {
  scope                = "${azurerm_resource_group.k8s.id}"
  role_definition_name = "Contributor"
  principal_id         = "${azuread_service_principal.k8s.id}"
}

resource "azurerm_log_analytics_workspace" "loganw" {
    name                = "${var.log_analytics_workspace_name}"
    location            = "${var.log_analytics_workspace_location}"
    resource_group_name = "${azurerm_resource_group.k8s.name}"
    sku                 = "${var.log_analytics_workspace_sku}"
}

resource "azurerm_log_analytics_solution" "logans" {
    solution_name         = "ContainerInsights"
    location              = "${azurerm_log_analytics_workspace.loganw.location}"
    resource_group_name   = "${azurerm_resource_group.k8s.name}"
    workspace_resource_id = "${azurerm_log_analytics_workspace.loganw.id}"
    workspace_name        = "${azurerm_log_analytics_workspace.loganw.name}"

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}
/*
resource "azurerm_route_table" "k8s" {
  name                = "aks-${var.dns_prefix}-routetable"
  location            = "${azurerm_resource_group.k8s.location}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"

  route {
    name                   = "default"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"
  }
}*/

resource "azurerm_virtual_network" "vnet" {
  name                = "aks-${var.dns_prefix}-network"
  location            = "${azurerm_resource_group.k8s.location}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "node-vnet" {
  name                 = "aks-node-subnet"
  resource_group_name  = "${azurerm_resource_group.k8s.name}"
  address_prefix       = "10.240.0.0/16"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"

  # this field is deprecated and will be removed in 2.0 - but is required until then
  #route_table_id = "${azurerm_route_table.k8s.id}"
}

resource "azurerm_subnet" "node-virtual" {

  name                 = "aks-virtualnode-subnet"
  resource_group_name  = "${azurerm_resource_group.k8s.name}"
  address_prefix       = "10.241.0.0/16"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"

  /* AKS creation will create the below delegation entry
   to prevent subsequent Terraform runs from failing please decomment the area
   https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#aci_connector_linux
    */
   delegation {
    name = "aciDelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

/*
resource "azurerm_subnet_route_table_association" "node-vnet" {
  subnet_id      = "${azurerm_subnet.node-vnet.id}"
  route_table_id = "${azurerm_route_table.k8s.id}"
}*/

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "${var.cluster_name}"
    location            = "${azurerm_resource_group.k8s.location}"
    resource_group_name = "${azurerm_resource_group.k8s.name}"
    dns_prefix          = "${var.dns_prefix}"

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = "${file("${var.ssh_public_key}")}"
        }
    }

    network_profile {
        network_plugin      = "azure"
        //network_policy      = "calico"/"azure"
        dns_service_ip      = "10.0.0.10"
        docker_bridge_cidr  = "172.17.0.1/16"
        service_cidr        = "10.0.0.0/16"
    }

    agent_pool_profile {
        name            = "agentpool"
        count           = "${var.agent_count}"
        vm_size         = "${var.vm_size}"
        os_type         = "Linux"
        os_disk_size_gb = 30

        # Required for advanced networking
        vnet_subnet_id = "${azurerm_subnet.node-vnet.id}"
    }

    service_principal {
        client_id     = "${azuread_application.k8s.application_id}"
        client_secret = "${azuread_service_principal_password.k8s.value}"
    }

    addon_profile {
        oms_agent {
            enabled                    = true
            log_analytics_workspace_id = "${azurerm_log_analytics_workspace.loganw.id}"
        }

        aci_connector_linux {
            enabled     = true
            subnet_name = "${azurerm_subnet.node-virtual.name}"
        }
    }

    tags {
        Environment = "Development"
    }
}