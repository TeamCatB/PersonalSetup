We deploy the packer built images out using MaaS (Metal as a Service) and HFS (HTTP File Server) (HFS is used to provide MaaS a URL to pull images from)

Pre-req set-up for a Debian-based distro
```
sudo apt-get install curl git wget
sudo snap install --channel=3.5 maas
Instructions to get MaaS and HFS set up on the deploying machine:
# installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# installs node
nvm install 20
echo gh:GigiaJ | sudo maas createadmin --username=<USERNAME> --email=<EMAIL>
sudo maas init rack
npx hfs@latest
```
This installs node, maas, configures maas, then installs and runs hfs.

Append to ~/.hfs/config.yaml:
```
port: 8080
create-admin: password
```
This sets the port to be above 1024 (1024 and lower require root). Then it sets a password for the local admin so we can set-up from there