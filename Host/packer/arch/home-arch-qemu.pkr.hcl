 variables {
  user = "root"
  password = "placeholder"
}

variable "account_username" {
  type = string
  description = "The username for the default user account."
}

variable "account_password" {
  type = string
  description = "The password for the default user account."
}

variable "account_fullname" {
  type = string
  description = "The full name of the individual who will use the account."
}

variable "encryption_passphrase" {
  type = string
  description = "The passphrase that will be used to decrypt the virtual hard drives with."
}

packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.9"
      source = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "arch" {
  efi_boot = true
  efi_firmware_code       = "/usr/share/edk2/x64/OVMF_CODE.4m.fd"
  efi_firmware_vars       = "/usr/share/edk2/x64/OVMF_VARS.4m.fd"
  boot_command = [
        "<enter><wait10><wait10><wait5>",
        "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/enable-ssh.sh<enter><wait5>",
        "passwd<enter><wait1>",
        "${var.account_password}<enter><wait1>",
        "${var.account_password}<enter><wait1>",
        "systemctl enable sshd<enter><wait1>",
        "systemctl start sshd<enter><wait1>"
  ]
  iso_url = "https://plug-mirror.rcac.purdue.edu/archlinux/iso/2024.06.01/archlinux-2024.06.01-x86_64.iso"
  iso_checksum = "sha256:4cc7e1c9f4e97b384f0d8731f317b5995bde256fcc17160d32359cab923c5892"
  disk_size = "100000M"
  format = "qcow2"
  accelerator = "kvm"
  http_directory = "./http"
  ssh_username = "root"
  ssh_password = "${var.password}"
  ssh_timeout = "30m"
  vm_name = "arch"
  net_bridge = "br0"
  disk_interface = "virtio"
  boot_wait = "2s"
  cpus = "4"
  qemuargs = [
    ["-m", "8128"],
  ]
}

build {
  sources = ["source.qemu.arch"]
  provisioner "shell" {
    environment_vars = [
      "DEFAULT_USERNAME=${var.user}",
      "DEFAULT_PASSWORD=${var.password}",
      "ACCOUNT_USERNAME=${var.account_username}",
      "ACCOUNT_PASSWORD=${var.account_password}",
      "ACCOUNT_FULLNAME=${var.account_fullname}",
      "ENCRYPT_PASSPHRASE=${var.encryption_passphrase}",
    ]
    scripts = [
      "scripts/presetup.sh",
      // # "scripts/preencrypt.sh",
      // # "scripts/encrypt.sh",
    ]
    pause_after = "15s"
    start_retry_timeout = "45s"
    max_retries = "3"
  }

}
