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
        # cat /sys/firmware/efi/fw_platform_size
}

# Generates a partition. Takes required positional arguments.
function buildPartition () {
        echo "n\n"
        # Primary or extended (is implied after the first)
        echo "$1\n"
        # Partition number
        echo "$2\n"
        # Partition start
        echo "$3\n"
        # Partition end
        echo "$4\n"
        # Change partition type
        echo "$5\n"
        # Partition number select
        echo "$6\n"
        # Partition type
        echo "$6\n"
}

# Prepare the partitions using fdisk; Takes device as a positional argument
function preparePartitions () {
        # Open device in fdisk
        fdisk $1
        # Set to GPT; it may default to MBR
        echo 'g\n'

        buildPartition "p" "" "" $bootSize "t" "" "1"
        buildPartition "" "" "" $swapSize "t" "" "19"
        buildPartition "" "" "" $rootSize "t" "" "23"
        buildPartition "" "" "" "" "t" "" "42"

        # Write changes to disk
        echo 'w\n'
}

# Format the partitions; Takes device as a positional argument
function formatPartitions () {
        # Format EFI system partition (boot)
        mkfs.fat -F 32 $11
        # Format swap file partition
        mkswap $12
        # Format root partition
        mkfs.ext4 $13
        # Format home partition
        mkfs.ext4 $14
}

# Mount the file systems; Takes device as a position argument
function mountFileSystems () {
        # Mount root to /m
        mount $13 /mnt
        # Make director and mount the EFI (boot) partition
        mount --mkdir $11 /mnt/boot
        # Make directory and mount the home partition
        mount --mkdir $14 /mnt/home
        # Activate swap partition
        swapon $12
}

function archSpecific () {
        # Arch's way of providing the bare essentials for getting a system running
        pacstrap -K /mnt base linux linux-firmware

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
        pacman -Syu grub efibootmgr

        # Installs GRUB to the efi directory
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

        # Exit the CHROOT
        exit

        # Reboots
        reboot
}

consoleConfiguration
preparePartitions $device
formatPartitions $device
mountFileSystems $device
archSpecific

