packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "hashicorp/vmware"
    }
  }
}

variable "iso_path" {
  type    = string
  default = "./Oracle-Linux-8.6-x86_64-dvd.iso"
}

source "vmware-iso" "oracle_linux" {
  iso_url            = var.iso_path
  communicator       = "ssh"
  ssh_username       = "root"
  ssh_password       = "oracle"
  shutdown_command   = "shutdown -h now"
  vm_name            = "ol-ansible-controller"
  disk_size          = 40960
  guest_os_type      = "centos7-64"
  network_adapter_type = "e1000"
}

build {
  name = "ol-ansible-controller"

  sources = ["source.vmware-iso.oracle_linux"]

  provisioner "shell" {
    inline = [
      "yum -y update",
      "yum -y install python3 python3-pip git curl vim",
      "pip3 install --upgrade pip ansible-core"
    ]
  }
}
