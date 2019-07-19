# Azure Kubernetes Server (AKS) IaC
## Prerequesits

1. Install Azure CLI
2. Install Terraform

## Edit variables.tf

| Variable | Description |
| --- | --- |
| agent_count | Amount of initial nodes (VMs) of the cluster |
| vm_size | VM size, the cheapest possible (@2019.7) is selected |
| ssh_public_key | please copy your id_rsa.pub key to folder ../shared/.ssh/. to get ssh access to the nodes |
| dns_prefix | DNS prefix of the cluster API |
| cluster_name | Name of your cluster |
| resource_group_name | The Azure resource group you want to create the cluster in |
| location | Azure Data Center location for the cluster |
| log_analytics_workspace_name | *The only value you have to change to be unique* |
| log_analytics_workspace_location | Azure Data Center location for Azure Monitor Log Analytics |
| log_analytics_workspace_sku | do not change |

## Creating AKS

Login to Azure CLI
~~~
az login
~~~

Be sure to set the subscription you want to work in to default
~~~
az account list
az account set --subscription <subsription_id>
~~~

Initialize Terraform providers (downloading and updating terraform modules)
~~~
terraform init
~~~

Plan the execution (can be skipped)
~~~
terraform plan
~~~

Apply changes to the infrastructure (create cluster and all required resources)
~~~
terraform apply
~~~

When you want to clean up
~~~
terraform destroy
~~~