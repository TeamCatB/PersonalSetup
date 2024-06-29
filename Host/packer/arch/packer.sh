#!/bin/bash
# intake a file to gen the keyfile from that will match the built file in the packer execution
PACKER_LOG=1 packer build -var='account_username=jaggar' -var='account_password=placeholder' -var='account_fullname=placeholder' -var='encryption_passphrase=ASecurePassphrase' home-arch-qemu.pkr.hcl
