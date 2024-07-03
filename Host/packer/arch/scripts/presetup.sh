#!/bin/bash

device="/dev/vda"
bootSize="+2G"
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
        sleep 1
        # Change partition type
        (echo "$5" \
        # Partition number select
        echo "$2" \
        # Partition type
        echo "$6"
        echo 'w') | fdisk $device
        sleep 1
}

# Prepare the partitions using fdisk
function preparePartitions () {
        # Set to GPT; it may default to MBR. Then write changes to disk.
        (echo 'g'; echo 'w';) | fdisk $device
        sleep 3
        buildPartition "" "1" " " $bootSize "t" "1"
        (echo 'a'; echo '1';) | fdisk $device
        buildPartition "" "2" " " $swapSize "t" "19"
        buildPartition "" "3" " " $rootSize "t" "23"
        buildPartition "" "4" " " " " "t" "42"
}

# Format the partitions
function formatPartitions () {
        # Format EFI system partition (boot)
        mkfs.vfat -F 32 "${device}1"
        sleep 1
        # Format swap file partition
        mkswap "${device}2"
        sleep 1
        # Format root partition
        mkfs.ext4 "${device}3"
        sleep 1
        # Format home partition
        mkfs.ext4 "${device}4"
        sleep 1
}

# Mount the file systems
function mountFileSystems () {
        # Mount root to /mnt
        mount --mkdir "${device}3" /mnt
        # Make director and mount the EFI (boot) partition
        mount --mkdir "${device}1" /mnt/boot
        # Make directory and mount the home partition
        mount --mkdir "${device}4" /mnt/home
        # Activate swap partition
        swapon "${device}2"

        # mount --bind /mnt/boot /boot
        # mount --bind /mnt/home /home
}

function encrypt () {
        echo -n $ENCRYPT_PASSPHRASE | cryptsetup luksFormat /dev/vdb1 - && \
        echo -n $ENCRYPT_PASSPHRASE | cryptsetup luksOpen /dev/vdb1 new_encrypted_home - && \
        echo -n $ENCRYPT_PASSPHRASE | cryptsetup luksFormat /dev/vda6 - && \
        echo -n $ENCRYPT_PASSPHRASE | cryptsetup luksOpen /dev/vda6 new_encrypted_var - && \
        echo -n $ENCRYPT_PASSPHRASE | cryptsetup luksFormat /dev/vda7 - && \
        echo -n $ENCRYPT_PASSPHRASE | cryptsetup luksOpen /dev/vda7 new_encrypted_root - && \
        echo -n $ENCRYPT_PASSPHRASE | cryptsetup luksFormat /dev/vda8 - && \
        echo -n $ENCRYPT_PASSPHRASE | cryptsetup luksOpen /dev/vda8 new_encrypted_swap - && \
        mkswap /dev/mapper/new_encrypted_swap && \
        swapon /dev/mapper/new_encrypted_swap && \
        swapoff /dev/mapper/new_encrypted_swap && \
        mkfs.ext4 /dev/mapper/new_encrypted_home && \
        mkfs.ext4 /dev/mapper/new_encrypted_var
}

function buildFSTab () {
    echo "UUID=$(blkid -s UUID -o value /dev/mapper/new_encrypted_swap) none swap defaults 0 0" >> /etc/fstab && \
echo "UUID=$(blkid -s UUID -o value /dev/mapper/new_encrypted_home) /home ext4 defaults 0 0" >> /etc/fstab && \
echo "UUID=$(blkid -s UUID -o value /dev/mapper/new_encrypted_var) /var ext4 defaults 0 0" >> /etc/fstab && \
echo "UUID=$(blkid -s UUID -o value /dev/vda7) / ext4 errors=remount-ro 0 1" >> /etc/fstab && \
echo "UUID=$(blkid -s UUID -o value /dev/vda1) /boot ext4 defaults 0 0" >> /etc/fstab && \
echo "/dev/sr0 /media/cdrom0 udf,iso9660 user,noauto 0 0" >> /etc/fstab && \
echo "/dev/sr1 /media/cdrom1 udf,iso9660 user,noauto 0 0" >> /etc/fstab && \
UUID_ROOT=$(cryptsetup luksUUID /dev/vda7) && \
echo "new_encrypted_root UUID=$UUID_ROOT none luks" >> /etc/crypttab && \
UUID_VAR=$(cryptsetup luksUUID /dev/vda6) && \
echo "new_encrypted_var UUID=$UUID_VAR none luks" >> /etc/crypttab && \
UUID_HOME=$(cryptsetup luksUUID /dev/vdb1) && \
echo "new_encrypted_home UUID=$UUID_HOME none luks" >> /etc/crypttab && \
UUID_SWAP=$(cryptsetup luksUUID /dev/vda8) && \
echo "new_encrypted_swap UUID=$UUID_SWAP none luks" >> /etc/crypttab
}

# Performs the behavior arch expects in chroot
function archChroot () {
        # Set time zone for system\
        ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime;
        # Sets hardware clock to the system set\
        hwclock --systohc;
        # Find and remove comment in locale-gen via sed
        sed -i 's/#LANG=en_US.UTF-8/LANG=en_US.UTF-8/g' /etc/locale.gen;
        # Run locale-gen
        locale-gen;
        # Locale configuration\
        echo 'LANG=en_US.UTF-8' > /etc/locale.conf;

        # Console keyboard layout\
        # echo 'KEYMAP=de-latin1' > /etc/vconsole.conf;

        # Sets the computer hostname
        echo $hostname > /etc/hostname;
        # Set the root account password. We do this in the Packer boot commands, so it isn't needed here.
        # passwd;
        # echo '${password}\n';
        # echo '${password}\n';
        # Creates a new initramfs, but isn't needed as pacstrap does this
        pacman -Sy mkinitcpio --noconfirm
        mkinitcpio -P
        # Installs bootctl as our bootloader
        bootctl install;
        bootctl;
}
export -f archChroot

# Provides setup for bootctl to be our bootloader
function bootctlLoaderEntries () {
        mkdir /mnt/boot/EFI
        mkdir /mnt/boot/loader
        mkdir /mnt/boot/loader/entries
        mkdir /mnt/boot/EFI/loader

        touch arch.conf

        echo "default  arch.conf" >> /mnt/boot/EFI/loader/loader.conf
        echo "timeout  4" >> /mnt/boot/EFI/loader/loader.conf
        echo "console-mode max" >> /mnt/boot/EFI/loader/loader.conf
        echo "editor   no" >> /mnt/boot/EFI/loader/loader.conf

        echo "title   Arch Linux" >> /mnt/boot/loader/entries/arch.conf
        echo "linux   /vmlinuz-linux" >> /mnt/boot/loader/entries/arch.conf
        echo "initrd  /initramfs-linux.img" >> /mnt/boot/loader/entries/arch.conf
        echo "options root=UUID=$(blkid -s UUID -o value ${device}3) rw" >> /mnt/boot/loader/entries/arch.conf
}

function archSpecific () {
        bootctlLoaderEntries


        # Arch's way of providing the bare essentials for getting a system running
        pacstrap -K /mnt base linux linux-firmware --noconfirm

        # Generate the file system table for the new system
        genfstab -U /mnt >> /mnt/etc/fstab

        # Ways to check if efivars are present
        # ls /sys/firmware/efi/efivars
        # efivar --list

        # Changes the root being used and runs the given function
        arch-chroot /mnt /bin/bash -c "archChroot"


        sleep 45
        #echo 'add_dracutmodules+=\"crypt lvm\"' > /etc/dracut.conf.d/crypto.conf; \
        #echo 'install_items+=\"/etc/crypttab /usr/sbin/dmsetup\"' >> /etc/dracut.conf.d/crypto.conf; \
        #dracut -f; \
        #grub-mkconfig -o /boot/grub/grub.cfg
        #         sed -i 's/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"cryptdevice=\\/dev\\/vda3:new_encrypted_root root=\\/dev\\/mapper\\/new_encrypted_root cryptdevice=\\/dev\\/vda2:new_encrypted_swap resume=\\/dev\\/mapper\\/new_encrypted_swap\"/' /etc/default/grub; \
        #

        #cryptsetup luksClose new_encrypted_root && \
#cryptsetup luksClose new_encrypted_var && \
#cryptsetup luksClose new_encrypted_home && \
#cryptsetup luksClose new_encrypted_swap


        # Exit the CHROOT
        return 0

        # Reboots
        # reboot
}

consoleConfiguration
preparePartitions
formatPartitions
mountFileSystems
archSpecific

