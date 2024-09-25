```
nmcli connection add con-name "bridge-br0" ifname br0 type bridge ipv4.method auto ipv6.method disabled connection.autoconnect yes stp no
nmcli connection add con-name "ethernet" ifname eno1 type bridge-slave master bridge-br0 connection.autoconnect yes
systemctl restart NetworkManager
```
On the host machine, once Packer is installed it will need root permissions so just run w/ sudo
On host machine, QEMU will need to be informed to use the network bridge br0 (can set this in virt-manager)
If installed on the host machine and ran raw, it is advised to change the VM encryption password once logged in

Debian has an issue involving DHCP sending Client UIDs after it installs
The install itself just does a simple bind to the HWID (Mac Address)
but once it boots it kicks that setting on and will get a new IP which makes Packer wait for the old IP which never is used
with the following preseed late command you can mitigate this:


This makes the following boot after install use the hardware identifier.








~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


sudo ip link del br-vlan10
sudo ip link del eno1.10

sudo ip link add link eno1 name eno1.10 type vlan id 10
sudo ip link set eno1.10 up
sudo ip link add name br-vlan10 type bridge
sudo ip link set br-vlan10 type bridge vlan_filtering 1
sudo ip link set eno1.10 master br-vlan10
sudo ip link set br-vlan10 up
sudo bridge vlan add dev br-vlan10 vid 10 self
sudo ip addr add 192.168.4.42/24 dev br-vlan10
sudo systemctl restart NetworkManager

sudo bridge vlan add dev eno1.10 vid 10


IF DOCKER IS INSTALLED YOU MUST
iptables -P FORWARD ACCEPT

https://bbs.archlinux.org/viewtopic.php?id=233727



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


pfSense Default VLAN tag should probably not be 1 as 1 is the default and it adds confusion to the setup
pfSense Speed and Duplex MUST BE SET TO AUTOSELECT AND NOT THE DEFAULT SETTING IT SHOWS

pfSense outbound rules:
WORKVPN 192.169.1.0/24 * * * Work_VPN * x

When adding a new interface you need to update the outbound rules (removing the old and swapping to auto then back to manual is how I did it)



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

docker run -it \
--name stable-diffusion \
--net=stable-diffusion-network \
--ip=192.168.4.100 \
--dns 8.8.8.8 \
--device=/dev/kfd \
--device=/dev/dri \
--group-add=video \
--ipc=host \
--cap-add=SYS_PTRACE \
--cap-add=NET_ADMIN \
--security-opt seccomp=unconfined \
-v $HOME/dockerx/stable-diffusion-webui/models:/dockerx/stable-diffusion-webui/models:ro \
stable-diffusion:latest


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


VMs setup script needs this:
sudo ip link add link enp1s0 name enp1s0.1 type vlan id 1
OR
nmcli con add type vlan con-name VLAN1 ifname enp1s0.1 dev enp1s0 id 1 ip4 192.168.4.25/24 gw4 192.168.4.1 ipv6.method disabled ipv4.dns "192.168.4.1 1.1.1.1"

Add ZSH to the installs


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Disable SSH via SSHD config file
Install Fail2Ban via APT
Add a veth between Caddy and Personal Wireguard
Add mention of wg-quick (it is amazing for quickly setting up a network device for Wireguard)
docker network create -d macvlan \
  --subnet=192.168.3.0/24 \
  --gateway=192.168.3.1 \
  --ip-range=192.168.3.128/28 \
  -o parent=br0 \
  stable-diffusion-network
