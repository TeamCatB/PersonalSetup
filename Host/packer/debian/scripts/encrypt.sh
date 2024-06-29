rm -f /etc/fstab && \
mkdir -p /mnt/new_encrypted && \
umount /new_root && \
mount /dev/vdb1 /mnt/new_encrypted && \
rsync -aAXv --delete /mnt/new_encrypted/ /home_tmp && \
umount /mnt/new_encrypted && \
mount /dev/vda6 /mnt/new_encrypted && \
rsync -aAXv --delete /mnt/new_encrypted/ /var_tmp && \
umount /mnt/new_encrypted && \
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
mkfs.ext4 /dev/mapper/new_encrypted_var && \
mount /dev/mapper/new_encrypted_home /home && \
mount /dev/mapper/new_encrypted_var /var && \
rsync -aAXv --delete /home_tmp/ /home && \
rsync -aAXv --delete /var_tmp/ /var && \
rm -rf /mnt/new_encrypted && \
rm -rf /var_tmp && \
rm -rf /home_tmp && \
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
echo "new_encrypted_swap UUID=$UUID_SWAP none luks" >> /etc/crypttab && \
mkfs.ext4 /dev/mapper/new_encrypted_root && \
mount /dev/mapper/new_encrypted_root /new_root && \
rsync -aAX / /new_root --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/new_root/*","/home/*","/var/*","/boot/*"} && \
mount --bind /dev /new_root/dev && \
mount --bind /proc /new_root/proc && \
mount --bind /sys /new_root/sys && \
mount --bind /boot /new_root/boot && \
mount --bind /var /new_root/var && \
mount --bind /home /new_root/home && \
chroot /new_root /bin/bash -c "\
echo 'add_dracutmodules+=\"crypt lvm\"' > /etc/dracut.conf.d/crypto.conf; \
echo 'install_items+=\"/etc/crypttab /usr/sbin/dmsetup\"' >> /etc/dracut.conf.d/crypto.conf; \
dracut -f; \
sed -i 's/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"cryptdevice=\\/dev\\/vda7:new_encrypted_root root=\\/dev\\/mapper\\/new_encrypted_root cryptdevice=\\/dev\\/vda8:new_encrypted_swap resume=\\/dev\\/mapper\\/new_encrypted_swap\"/' /etc/default/grub; \
grub-mkconfig -o /boot/grub/grub.cfg" && \
umount /new_root/boot && \
umount /new_root/dev && \
umount /new_root/sys && \
umount /new_root/proc && \
umount /new_root/var && \
umount /new_root/home && \
umount /new_root && \
umount /var && \
umount /home && \
cryptsetup luksClose new_encrypted_root && \
cryptsetup luksClose new_encrypted_var && \
cryptsetup luksClose new_encrypted_home && \
cryptsetup luksClose new_encrypted_swap
