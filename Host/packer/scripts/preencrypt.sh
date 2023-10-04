sudo sed -i.bak '/\/var/d' /etc/fstab
sudo sed -i.bak '/\/home/d' /etc/fstab
sudo sed -i.bak '/swap/d' /etc/fstab
reboot
