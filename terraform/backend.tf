# Bootstrap this manually before `terraform init` — Terraform can't create
# the storage account its own state depends on.
#
#   az group create --name rg-tfstate --location centralus
#   az storage account create --name <globally-unique-name> --resource-group rg-tfstate --sku Standard_LRS
#   az storage container create --name tfstate --account-name <that-name>
#
# Azure may append digits if your requested storage account name is already
# taken globally — confirm the real name with `az storage account list`
# before pasting it below.

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstatelabs363689"
    container_name        = "tfstate"
    key                    = "ntfs-lab.tfstate"
  }
}
