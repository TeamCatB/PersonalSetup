# Isolation Cloud Development Environment


## Summary
This all serves to enable code-server an encrypted VHD VM generated via Packer protected by a 2FA Oauth2 running via QEMU on an encrypted host machine w/ a TAP device for layer 2 traffic routed to using the Wireguard peer IP on a pfsense router through the use of entries on the NAT table and the host device firewalled off from any traffic. On the other end of the Wireguard tunnel is a VPS Wireguard container which serves to provide an Unbound DNS server container hosts to the peers for intranet access.
Alongside this is a self-hosted cloud storage implementation using Wasabi and Nextcloud.

This will walk through the process utilized to establish a well-fortified, limited access, virtual machine used for development purposes such as code-server or Jetbrain's Gateway.
The instructions are particular to my set-up, but can be substituted as needed.



## Pre-requisites
There are several technologies at play for the set-up and most of the major pieces are listed below:
- [QEMU]
- [Packer]
- [Virtual Private Server]
- [Domain]
- [Docker]
- [Unbound DNS]
- [Wireguard]
- [Wasabi]
- [Nextcloud]
- [pfSense]
- [Code-server]
- [Caddy]
- [Jetbrains Gateway]

Setting up the pre-requisites as needed goes as follows:
### QEMU

QEMU (Quick Emulator) is an open-source machine emulator and virtualizer that allows users to run operating systems and applications made for one machine on another different machine. It can be used in a standalone mode to provide emulation, or alongside KVM (Kernel-based Virtual Machine) to provide hardware-assisted virtualization for improved performance.

#### Virt Manager and Packages
The main packages needed are generally qemu-systems and virt-manager
For a Debian-based distro:
`sudo apt-get install qemu-system virt-manager`

#### Network Manager
A network bridge needs to be made so that the VM utilizes the physical ethernet port and is connected directly to the network. This will bypass the host machines networking and thus nothing touches the host.
To set up the bridge that will be used for QEMU VMs do the following (substitute eno1 with your ethernet device):

```
nmcli con add type bridge ifname br0 ipv4.method auto ipv6.method disabled connection.autoconnect yes stp no
nmcli connection add con-name "ethernet" ifname eno1 type bridge-slave master bridge-br0 connection.autoconnect yes
systemctl restart NetworkManager
```

#### VM Setup
Once you use Packer to build the image this part is fairly simple if you use the virt-manager GUI. You need to add the connection to QEMU/KVM. Then you need to import an existing disk image.


### Packer

#### Background
Packer is used for us to create easily mutable golden images. This is done through describing the process in which the image is made instead of the classical replication of said image. The result is a robust and reusable implementation that provides a diverse set of options towards building a deployment fleet.

In our case, however, we take it to a different usage. This, while similar, is to pursue the creation of quickly creatable and disposable virtual development environments. Now one could easily do that with Docker volume storage, yes. However, let us assume you want to create *encrypted* volumes, swappable home directories, non-host based networking (you can't, or can't easily set up TAP interfaces inside the docker container for example).
Docker is a jail and not a virtual machine. It shares the kernel with the host. It shares resources between containers (meaning one can consume all). The container is easier to break out of than a VM (it isn't isolated properly like a hypervisor). Some resources aren't namespaced.
Virtual machines are easier to secure and more effective at it as well. It might be overkill, but it is correct.

#### Extra details

##### Packer file
This file simply outlines the builders that'll be used and how they should behave. We define some variables to be passed to the build alongside specifying an additional disk for example. This is where you would update the iso_url and the iso_checksome too.

##### Preseed details
At one point during the creation Debian 11 on small installs of 5 GB or so would send a different Client UID after install (or perhaps at install it doesn't send one at all. I didn't have the gear at the time to check easily). This meant that Packer would effectively be looking for the same IP, but the virtual machine actually now had a new one. We rectified this on small installs via a late-command in the preseed:
```
d-i preseed/late_command string echo "send dhcp-client-identifier = hardware;" >> /target/etc/dhcp/dhclient.conf;
```
Alternatively, you could just install at a size of 10 GB and ignore the issue.


We also opt to using an expert recipe to set up some of the general partition layout. We then append the late-command described above to delete the default user (as you can't go through the Debian installer without creating one) and create a new volume for the home partition on a *SECOND* disk. This is key because it allows us to at a later time retain our home directory and swap out the root filesystem for an update variant. This is only effective if the install script is properly prepared to install all existing software.

We also opt for installing a few extrra packages like openssh-server (for SSHing into the VM), parted and fdisk (for our home directory late-command), cryptsetup (for our encryption script), and dracut (for configuring the initramfs. update-initramfs should really never be used as the tool is overtly complex and generally it'd be faster for you to generate your own and then set up the swap_root to execute in there after prompting for decrypting drives. It's really just not worth using over dracut.)

##### Scripts
We use four scripts for this setup.
- Presetup just generates the user account on your behalf and adds it to the sudoers group.
- Setup provides the set up of programs for the VM installing what is needed and providing the Packer runner an easy point of modification to appending to the setup process.
- Preencrypt deletes /var /home /swap from the FSTAB so that we don't encounter errors with them being mounted on next boot and then restarts the VM.
- Encrypt is a bit more complex than the rest and creates new encrypted partitions by creating a temporary folder and storing the data then wiping the old location and encrypting it followed by moving the data back into the now encrypted partition. The rootfs is encrypted through a more direct method of copying the data into an encrypted partition and then deleting the fstab and adding all the newly encrypted devices to it instead.

#### Install
Install details can be found here:
https://developer.hashicorp.com/packer/downloads
For a Debian-based distro:
```
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer
```

#### Usage
An example script file is provided, but it is short so no harm in adding it here:

```
PACKER_LOG=1 packer build -var='account_username=MyName' -var='account_password=Password' -var='account_fullname=My Name' -var='encryption_passphrase=ASecurePassphrase' oceanspray-debian-qemu.pkr.hcl
```

PACKER_LOG can be omitted, but it provides some details about what is going on. All the entries in there should generally be updated and if the VM is to run on the same device it might be advisable to update the encryption password upon logging into your VM.


### Virtual Private Server

A Virtual Private Server is just a virtual machine running on a phyiscal server somewhere in a data center in which you have access to.

The immediate thing would be to acquire a Virtual Private Server host. Personally I use vultr, but you're welcome to shop around.
The next step after acquiring one (I don't know many, but I assume all provide an OS for you to use) and having it defaulted to whatever you like is to SSH into it.
We want Caddy and Docker for what we plan to do.


```sudo apt-get install docker caddy```

Caddy, *while technically not needed*, is going to be used for a reverse proxy server that will direct to our containers accordingly. This allows us more granularity on our routing to services long-term.
We're going to containerize our applications for this portion as upkeep of these services is easier when they're easily deployable containers.

### Domain

A domain is useful for hosting stuff behind a human-readable and writeable name.

The first step here is to acquire a domain. I'd recommend Cloudflare for general ease as having them host and handle DNS is optimal, but I personally bought a cheap Domain and then handle my DNS through Cloudflare in steps I won't detail here.

Using Cloudflare can handle your DNS and allow you to set A names and such for your domain. Set up what you need so that you can direct traffic to your Virtual Private Server's IP address.

Also grab an API token for later and keep that somewhere safe until then. We'll need it to set-up Caddy easily.


### Docker
(On VPS)

Docker provides a platform to easily deploy applications within containers, ensuring isolation and consistent environments. Drawing parallels with FreeBSD's "jails" and Linux's "chroot", Docker enhances these concepts with a suite of features that simplify container interaction. Coupled with a vast repository of public images for a myriad of applications, Docker is an invaluable tool that every developer should consider mastering.

Detailed below are some pre-requisites needed for the containers themselves


We need to modifiy systemd-resolved as that is how systemd configures what DNS servers to use for resolving hostnames.

We can do this by modifying the `/etc/systemd/resolved.conf` and adding:

```
DNSStubListener=no
```

Then we need to restart systemd-resolved via

```
systemctl restart systemd-resolved
```

Then make a config file to source from for the Docker container

```
mkdir ~/dockerconfigs
touch a-records.conf
```

Then just add in your contents like so:
```
# A Record
        local-data: "your.domain.com. A 192.168.255.10"

# PTR Record

```
**The period after your.domain.com is intentional. Do not remove it.**


Now to link the Wireguard container to our Unbound DNS server container we need to make a Docker network bridge

```
docker network create --driver=bridge --subnet=192.168.10.0/24 custom-network
```

That network name will be used in the commands for Unbound and Wireguard to make them use the bridged network (and thus enable them to see eachother and direct traffic to one another)
The IP can be set to whatever technically, but be certain it doesn't clash with your downstream networks (on your router for example) for Wireguard too
Similarly the name can be whatever, but make sure to use that name in the later commands.


### Wasabi
(In Nextcloud UI and on Wasabi's website)

Wasabi is an affordable cloud storage provider known for its S3 compatibility, high speeds, flat pricing, robust encryption, and data immutability features, making it a competitive alternative to giants like Amazon S3.
**A big emphasis, however, on no egress or API request fees**

Create a Wasabi account:
Visit the Wasabi website and sign up if you haven't already.

Log into the Wasabi Console:
Navigate to the Wasabi Management Console and sign in with your account credentials.

Create an S3 bucket:
Click on the “Buckets” link in the left navigation panel.
Click on the “Create Bucket” button.
Choose a unique name for your bucket and select a region that's closest to your Nextcloud server to minimize latency.
Leave the rest of the settings as default and create the bucket.

Create Access Keys:
Click on “Access Keys” under "IAM" in the left navigation panel.
Click on the “Create New Access Key” button.
Save the provided Access Key ID and Secret Access Key securely. You'll need these to configure Nextcloud.


### Nextcloud
(On VPS)
Container github: https://github.com/nextcloud/all-in-one

Nextcloud is an open-source software suite that allows users to store their data (like files, calendars, contacts, and more) securely and accessibly. Essentially, it's a self-hosted productivity platform that offers the benefits of online cloud services like Dropbox, Google Drive, or Microsoft OneDrive but on servers you control.

Now for installing the container:
```
sudo docker run --init --sig-proxy=false --name nextcloud-aio-mastercontainer --restart always --publish 8080:8080 --env APACHE_PORT=11000 --env APACHE_IP_BINDING=0.0.0.0 --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config --volume /var/run/docker.sock:/var/run/docker.sock:ro nextcloud/all-in-one:latest
```

This allows us to use Caddy on the VPS to route easier to the Nextcloud container by configuring the Apache server more effectively.
If you opted against the Caddy reverse proxy than check the documentation for normal docker run. https://github.com/nextcloud/all-in-one#how-to-use-this


Now for configuring Wasabi with Nextcloud

Log into your Nextcloud instance:
Sign in as an admin user.

Navigate to the external storage settings:
Click on your profile picture in the top right corner and select “Settings.”
In the left pane, click on “External storages” under the “Administration” section.


Add an S3 bucket:
Click on the “Add storage” drop-down menu and select “Amazon S3.”

Fill out the following fields:
Bucket: Your Wasabi bucket name.
Access Key: The Access Key ID you got from Wasabi.
Secret Key: The Secret Access Key from Wasabi.
Hostname: s3.wasabisys.com (or the endpoint relevant to your Wasabi region).
Port: 443.
Region: Leave blank or fill in the region you chose in Wasabi.
Use SSL/TLS: Checked.
Legacy (v2) authentication: Unchecked.
Save the configuration:

Click on the check mark or the save icon (depending on your Nextcloud version) to save the settings.



### Unbound DNS
(On VPS)
Container github: https://github.com/MatthewVance/unbound-docker

Unbound is an open-source, recursive DNS resolver. It's designed to be fast and secure, focusing on providing a robust DNS service. Notable features include DNSSEC validation for ensuring DNS query authenticity and caching abilities to enhance query response times. Often used in infrastructure setups for its modularity and efficiency, Unbound can serve as a local DNS cache, protect against DNS-based threats, and ensure the authenticity of DNS responses.

To actually install the container (ensure the pre-req works is done)

You can set the name to whatever you'd like and the IP **is the IP for the DNS server that will be used for configuring Wireguard too**
The volume should point to the file you made (easiest if you just change directories to where it lives and then run the command)

```
docker run \
--network=custom-network \
--name dns-container \
--detach=true \
--ip=192.168.10.25 \
--publish=53:53/tcp \
--publish=53:53/udp \
--restart=unless-stopped \
--volume $(pwd)/a-records.conf:/opt/unbound/etc/unbound/a-records.conf:ro \
mvance/unbound:latest
```



### Wireguard
(On VPS)
Container github: https://github.com/linuxserver/docker-wireguard

WireGuard is an open-source VPN (Virtual Private Network) protocol designed to offer a simple interface, fast performance, and modern encryption techniques. Prioritizing ease of implementation and maintenance, it outperforms many legacy VPN protocols and has rapidly gained popularity for its streamlined codebase and security features.


To set up the Wireguard container on the VPS run the following command:
```
docker run -d \
  --name=vpn-container \
  --cap-add=NET_ADMIN \
  --network=custom-network \
  --cap-add=SYS_MODULE \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e SERVERURL=<vpn.yourdomain.com> \
  -e SERVERPORT=51820 \
  -e PEERS=pfsense,<YOURNAMEHERE> \
  -e PEERDNS=192.168.10.25 \
  -e INTERNAL_SUBNET=10.13.13.0 \
  -e ALLOWEDIPS=0.0.0.0/0 \
  -e PERSISTENTKEEPALIVE_PEERS=all \
  -e LOG_CONFS=true \
  -p 51820:51820/udp \
  -v /.config:/config \
  -v /lib/modules:/lib/modules \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --restart unless-stopped \
  lscr.io/linuxserver/wireguard:latest
```

Feel free to change the name, add more peers (and obviously set the name for the peer in <>), update the serverurl to your domain

After this then do (this effectively places you inside the Docker container)

```
docker container exec -it vpn-container /bin/bash
```

Inside the Docker container run

```
cd config
cat wg0.conf
```
And note the **INTERFACE** private key, port, and address (the public key is resolved from the private)

And you can grab your peer configs here or if you left LOG_CONFIGS true in the docker run command then you can do
```
docker logs vpn-container
```
And it'll show QR codes for the peer info


### pfSense
pfSense is an open-source firewall and router software distribution based on FreeBSD. Known for its reliability and versatility, pfSense provides a plethora of features including stateful firewalling, VPN capabilities, load balancing, and network monitoring.



Set up the tunnel on the pfSense/router using the interface configurations from the previous section
Now we'll set up a peer on the pfsense with the peer_pfsense configurations
Now bind the device wg0 to an interface in the interface section

Now go to the interface and assign the IPv4 address to the address provided for that respective peer
(so it'll likely be 10.13.13.2 if you didn't change the Internal Subnet)

Then create a Gateway (under the drop down for System then select Routing)
Set the interace to the Wireguard VPN interface and assign the address to the address you saw for **Interface** in the Wireguard container
(so it'll likely be 10.13.13.1 if you didn't change the Internal Subnet)

This is vital.

After this set-up the NAT entries in whatever manner you'd like.
Just as a quick refresher the firewall handles what can come in and out. NAT handles where traffic comes in and out is routed. (Generally, Firewall what, NAT where)


You'll also want to configure the DHCP assignments for the VM created by Packer and you should do so while you're in here


### code-server
Github: https://github.com/coder/code-server

code-server is an open-source tool that allows developers to run Visual Studio Code, a popular code editor, in a web browser. It enables remote development by providing the VS Code environment on a server, which can be accessed from any device with a browser. This flexibility is especially beneficial for cloud-based development or situations where accessing a consistent development environment from various locations is paramount.

code-server runs an install script so the only commands needed to install are:
```
curl -fsSL https://code-server.dev/install.sh | sh
```

```
sudo systemctl enable --now code-server@$USER
```

### Caddy

Caddy repo: https://github.com/caddyserver/caddy
Caddy-security container source: https://github.com/greenpau/caddy-security

Caddy is an open-source web server written in Go. Distinguished by its automatic HTTPS by default using Let's Encrypt, Caddy simplifies web server configuration and security. It's designed to be lightweight and extensible, supporting a variety of web services and applications. Its intuitive configuration and built-in features make it an attractive choice for modern web hosting needs.



Firstly, I'd recommend using Github for Oauth for simplicity sake located here: https://github.com/settings/developers

The home page URL should be the URL you plan to use to access code-server: `https://your.domain.com`
The authoirization callback url should be the *auth portal* (Caddy's security plugin will provide this): `https://auth.domain.com`

From this point you can start setting up Caddy on the VM to bind our OAuth2 application to our code-server instance as well as providing certs for the code-server as well.

We use Cloudflare for our DNS configurations and domain services. It just simplifies the process as Cloudflare tends to be in the forefront with tech.
Github as our authentication provider as it eases the approach we use (since Github provides easy and effective MFA to accounts and thus sign ins or even use an ORG SAML SSO authentication)
Caddy is our choice for a reverse proxy for simplicity and modularity.
Docker is helpful for hosting the Caddy reverse proxy server since we can limit the ports available to the Caddy web server to a single port for easier, more locked down routing.

The Caddyfile uses environment variables
- GITHUB_CLIENT_ID
    - Can be obtained making an Oauth app in Github
- GITHUB_CLIENT_SECRET
    - Can be obtained making an Oauth app in Github
- CLOUDFLARE_API_TOKEN
    - Can be obtained with a Cloudflare account
- JWT_SHARED_KEY
    - Can be obtained using uuidgen or really any method

I'd recommend making a .env file (if you're unfamiliar that is a file literally just named .env) and storing the values in there like
```
GITHUB_CLIENT_ID=<GITHUBOAUTHAPPID>
GITHUB_CLIENT_SECRET=<GITHUBOAUTHAPPSECRET>
CLOUDFLARE_API_TOKEN=<TOKENFROMCLOUDFLARE>
JWT_SHARED_KEY=<RANDOMKEYHERE>
```

You'll need a Docker file that looks like:
```
FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/greenpau/caddy-security \
    --with github.com/caddy-dns/cloudflare
FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

COPY ./Caddyfile /etc/caddy/Caddyfile
```

The Caddyfile will look like this:
(Be sure to change <GITHUB_USERNAME> and the reverse_proxy IP if needed)
```
{
	http_port 8080
	https_port 443

	order authenticate before respond
	order authorize before basicauth

	security {
		oauth identity provider github {env.GITHUB_CLIENT_ID} {env.GITHUB_CLIENT_SECRET}

		authentication portal myportal {
			crypto default token lifetime 3600
			crypto key sign-verify {env.JWT_SHARED_KEY}
			cookie domain domain.com
			enable identity provider github

			transform user {
				match realm github
				action add role authp/user
			}

			transform user {
				match realm github
				match sub github.com/<GITHUB_USERNAME>
				action add role authp/admin
			}
		}

		authorization policy mypolicy {
			set auth url https://auth.domain.com/
			crypto key verify {env.JWT_SHARED_KEY}
			allow roles authp/admin authp/user
			validate bearer header
			inject headers with claims
		}
	}
}

(tls_cloudflare) {
    tls {
        issuer acme {
            dir https://acme-v02.api.letsencrypt.org/directory
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        }
        issuer zerossl {
            dir https://acme.zerossl.com/v2/DV90
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        }
    }
}

auth.domain.com{
	import tls_cloudflare
	authenticate with myportal
}

your.domain.com{
	import tls_cloudflare
	authorize with mypolicy
	reverse_proxy 127.0.0.1:8080
}
```


Now you'll want to be in the same directory as the Caddyfile and Dockerfile for the next bit

```
docker build -t caddy .
```

```
docker run --env-file .env --name caddy -d -p 443:443 caddy
```


### Jetbrains Gateway


