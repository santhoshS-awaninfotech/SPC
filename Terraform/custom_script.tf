resource "azurerm_virtual_machine_extension" "cscrp" {
  name                 = "sant-cuscript-extn"
  virtual_machine_id   = azurerm_windows_virtual_machine.spcvm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "fileUris": ["https://stawan.blob.core.windows.net/sant/boot.ps1?sp=r&st=2026-03-12T09:59:09Z&se=2026-03-12T18:14:09Z&spr=https&sv=2024-11-04&sr=b&sig=htcgwLK0Ph2WkfyWmluoSof12YS%2FNLFrefo06zNBvPA%3D"],
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