#!/bin/bash
PACKER_LOG=1 packer build -var='account_username=jaggar' -var='account_password=Cranberry1930!' -var='account_fullname=Jaggar Boone' -var='encryption_passphrase=ASecurePassphrase' personal-debian-qemu.pkr.hcl
