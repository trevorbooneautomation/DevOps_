variable "rsg_name" {
  description = "The name of the resource group."
}

variable "computername" {
  description = "The name of the virtual machine."
}

variable "os_type" {
  description = "Specifies the operating system type."
  default     = "windows"
}

variable "command" {
  default     = ""
  description = "Command to be executed."
}

variable "script" {
  default     = ""
  description = "Script to be executed."
}

variable "file_uris" {
  type        = "list"
#  default     = []
  default     = ["https://azure.file.core.windows.net/deploy/power.ps1"]
  description = "List of files to be downloaded."
}

variable "timestamp" {
  default     = ""
  description = "An integer, intended to trigger re-execution of the script when changed."
}

variable "tag_name" {
  default     = {}
  description = "A mapping of tags to assign to the extension."
}

variable "tag_value" {

}

variable "location" {

}

variable "filename" {

}
