resource "azurerm_storage_blob" "boot_script" {
  name                   = "boot.ps1"
  storage_account_name   = "stawan"
  storage_container_name = "sant"
  type                   = "Block"
  source                 = "${path.module}/scripts/boot.ps1"
}

resource "azurerm_virtual_machine_extension" "cscrp" {
  name                 = "sant-cuscript-extn"
  virtual_machine_id   = azurerm_windows_virtual_machine.spcvm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "fileUris": ["https://stawan.blob.core.windows.net/sant/boot.ps1?sp=r&st=2026-03-16T07:30:10Z&se=2026-03-21T15:45:10Z&spr=https&sv=2024-11-04&sr=b&sig=3e2EC9RC9%2Bjf9ScnEhZuP%2FotsO8fSGF6B5BFlI15usU%3D"],
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File boot.ps1"
    }
  SETTINGS

  protected_settings = <<PROTECTED
    {
      "environmentVariables": {
        "USERA_PASSWORD": "${var.userA_password}",
        "USERB_PASSWORD": "${var.userB_password}",
        "PGSQLPASSWORD" : "${var.pgsql_password}"
      }
    }
  PROTECTED

 }