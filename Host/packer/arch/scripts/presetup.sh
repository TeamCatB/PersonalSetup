#!/bin/bash

device="/dev/vda"
bootSize="+1G"
swapSize="+32G"
rootSize="+32G"
hostname="Catdog2"

# Configures the console for the install
function consoleConfiguration () {
        # localectl list-keymaps
        # loadkeys us
        # setfont
        cat /sys/firmware/efi/fw_platform_size
}

# Generates a partition. Takes required positional arguments.
function buildPartition () {

        # Declare a new partition
        (echo "n" \
        # Primary or extended (is implied after the first)
        echo "$1" \
        # Partition number
        echo "$2" \
        # Partition start
        echo "$3" \
        # Partition end
        echo "$4" \
        # Write changes to disk
        echo 'w') | fdisk $device
        sleep 5
        # Change partition type
        (echo "$5" \
        # Partition number select
        echo "$2" \
        # Partition type
        echo "$6"
        echo 'w') | fdisk $device
        sleep 5
}

# Prepare the partitions using fdisk
function preparePartitions () {
        # Set to GPT; it may default to MBR. Then write changes to disk.
        (echo 'g'; echo 'w';) | fdisk $device
        sleep 10
        buildPartition "p" "1" " " $bootSize "t" "1"
        buildPartition "" "2" " " $swapSize "t" "19"
        buildPartition "" "3" " " $rootSize "t" "23"
        buildPartition "" "4" " " " " "t" "42"
}

# Format the partitions
function formatPartitions () {
        # Format EFI system partition (boot)
        mkfs.fat -F 32 "${device}1"
        # Format swap file partition
        mkswap "${device}2"
        # Format root partition
        mkfs.ext4 "${device}3"
        # Format home partition
        mkfs.ext4 "${device}4"
}

# Mount the file systems
function mountFileSystems () {
        # Mount root to /m
        mount "${device}3" /mnt
        # Make director and mount the EFI (boot) partition
        mount --mkdir "${device}1" /mnt/boot
        # Make directory and mount the home partition
        mount --mkdir "${device}4" /mnt/home
        # Activate swap partition
        swapon "${device}2"
}

function archSpecific () {
        # Arch's way of providing the bare essentials for getting a system running
        pacstrap -K /mnt base linux linux-firmware --noconfirm

        # Generate the file system table for the new system
        genfstab -U /mnt >> /mnt/etc/fstab

        # Change root into the /mnt which holds our new system
        arch-chroot /mnt

        # Set time zone for system
        ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

        # Sets hardware clock to the system set
        hwclock --systohc

        # Find and remove comment in locale-gen via sed
        sed -i 's/#LANG=en_US.UTF-8/LANG=en_US.UTF-8/g' /etc/locale.gen

        # Run locale-gen
        locale-gen

        # Locale configuration
        echo "LANG=en_US.UTF-8" > /etc/locale.conf

        # Console keyboard layout
        # echo "KEYMAP=de-latin1" > /etc/vconsole.conf

        echo $hostname > /etc/hostname

        # Creates a new initramfs, but isn't needed as pacstrap does this
        # mkinitpico -P

        # Set the root account password. We do this in the Packer boot commands, so it isn't needed here.
        # passwd
        # echo "${password}\n"
        # echo "${password}\n"

        # Install package for GRUB and efibootmgr
        pacman -Syu grub efibootmgr --noconfirm

        # Installs GRUB to the efi directory
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

        # Exit the CHROOT
        exit

        # Reboots
        reboot
}

consoleConfiguration
preparePartitions
formatPartitions
mountFileSystems
archSpecific

