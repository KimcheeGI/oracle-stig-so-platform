packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "iso_path" {
  type    = string
  default = "C:/ISOs/OracleLinux-R9-U8-x86_64-dvd.iso"
}

source "vmware-iso" "oracle_linux" {
  iso_url              = var.iso_path
  iso_checksum         = "none"
  communicator         = "ssh"
  ssh_username         = "root"
  ssh_password         = "CyberSecurity123!"
  ssh_wait_timeout     = "30m"
  shutdown_command     = "shutdown -h now"
  vm_name              = "ol-ansible-controller"
  output_directory     = "output-oracle_linux"
  disk_size            = 40960
  guest_os_type        = "rhel9-64"
  network_adapter_type = "e1000"
  memory               = 4096
  cpus                 = 2
  
  # Force BIOS mode so isolinux menu appears (not GRUB2/EFI)
  firmware             = "bios"
  headless             = true

  # Wait 10s for isolinux menu to appear.
  # Must be LESS than the 60s isolinux countdown or menu auto-boots.
  boot_wait            = "10s"
  boot_command = [
    "<tab><wait>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg inst.text<enter><wait>"
  ]
  
  # Enable HTTP server for kickstart
  http_directory       = "c:/Scripts/oracle-stig-so-platform/packer"
  http_port_min        = 8000
  http_port_max        = 9000
  
  # SSH connection details for post-installation
  ssh_read_write_timeout = "5m"
  skip_compaction      = false
}

build {
  name = "ol-ansible-controller"

  sources = ["source.vmware-iso.oracle_linux"]

  # Verify the installation is complete and working
  provisioner "shell" {
    inline = [
      "echo '=== Build verification ==='",
      "hostname",
      "ip addr show | grep 'inet '",
      "python3 --version",
      "ansible --version | head -1",
      "echo '=== Build complete ==='"
    ]
  }
}
