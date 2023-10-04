 variables {
  user = "packer"
  password = "packer"
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
source "qemu" "debian" {
  boot_command = [
        "<esc><wait>",
        "auto <wait>",
        "netcfg/use_autoconfig=true ",
        "netcfg/confirm_static=true <wait>",
        "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>",
        "<enter><wait>",
        "<wait><wait><enter>"
  ]
  iso_url = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.0.0-amd64-netinst.iso"
  iso_checksum = "sha512:b462643a7a1b51222cd4a569dad6051f897e815d10aa7e42b68adc8d340932d861744b5ea14794daa5cc0ccfa48c51d248eda63f150f8845e8055d0a5d7e58e6"
  disk_size = "100000M"
  format = "qcow2"
  disk_additional_size = ["100000M"]
  accelerator = "kvm"
  http_directory = "./http"
  ssh_username = "root"
  ssh_password = "${var.password}"
  ssh_timeout = "30m"
  vm_name = "personal"
  net_bridge = "br0"
  disk_interface = "virtio"
  boot_wait = "2s"
  cpus = "4"
  qemuargs = [
    ["-m", "4096"],
  ]
}

build {
  sources = ["source.qemu.debian"]

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
      "scripts/setup.sh",
      "scripts/preencrypt.sh",
      "scripts/encrypt.sh",
    ]
    pause_after = "15s"
    start_retry_timeout = "45s"
    max_retries = "3"
  }

}
