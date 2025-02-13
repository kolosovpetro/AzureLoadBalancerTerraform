provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = "1b08b9a2-ac6d-4b86-8a2f-8fef552c8371"
}
