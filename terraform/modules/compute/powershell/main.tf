#locals {
#  settings_windows = {
#    fileUris = "${var.file_uris}"
#  }

#   protected_settings = {
#      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File '${var.file_uris}${var.filename}'",
#      "storageAccountName": "compassterraformstate",
#      "storageAccountKey": "dvCRrRhHM7rAzbaLPxKVs8m1Yk/rRYrKwHQcqawCgSCEXpO8D91lu689ZheP1pZWfPFa3bMLu479oQwQGtFbYA=="
#  }
#}

resource "azurerm_virtual_machine_extension" "windows" {
  count                      = "${lower(var.os_type) == "windows" ? 1 : 0}"
  name                       = "${var.computername}-run-command"
  location                   = "${var.location}"
  resource_group_name        = "${var.rsg_name}"
  virtual_machine_name       = "${var.computername}"
#  publisher                  = "Microsoft.CPlat.Core"
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
#  type                       = "RunCommandWindows"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true
#  settings                   = "${jsonencode(local.settings_windows)}"
    tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }
#  protected_settings         = "${jsonencode(local.protected_settings)}"

    settings = <<SETTINGS
    {
        "fileUris": "https://compassterraformstate.file.core.windows.net/deploy/power.ps1",
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ${var.filename}"
    }
SETTINGS

}
