variable "agent_count" {
    default = 1
}

variable "vm_size" {
  default = "Standard_B2s" // "Standard_DS1_v2" 
}


variable "ssh_public_key" {
    default = "../shared/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
    default = "cse"
}

variable cluster_name {
    default = "cseflorian"
}

variable resource_group_name {
    default = "AKSrg"
}

variable location {
    default = "japaneast"
}

variable log_analytics_workspace_name {
    default = "cseflorianloganalytics"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "japaneast"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}