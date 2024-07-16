We deploy the packer built images out using MaaS (Metal as a Service) and HFS (HTTP File Server) (HFS is used to provide MaaS a URL to pull images from)

Pre-req set-up for a Debian-based distro
Personally using an Odroid using Armbian.
https://www.armbian.com/odroid-m1/

```
sudo apt-get install curl git wget
sudo snap install --channel=3.5 maas
Instructions to get MaaS and HFS set up on the deploying machine:
# installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# installs node
nvm install 20
MAAS_USERNAME=USERNAMEHERE
MAAS_EMAIL=EMAILHERE
MAAS_DBUSER=USERNAMEHERE
MAAS_DBPASS=PASSWORDHERE
MAAS_DBNAME=DBNAMEHERE
HOSTNAME=localhost
sudo -i -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
sudo -i -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
sudo mkdir -p /etc/postgresql/14/main
sudo touch /etc/postgresql/14/main/pg_hba.conf
echo "host    $MAAS_DBNAME    $MAAS_DBUSER    0/0     md5" | sudo tee -a /etc/postgresql/14/main/pg_hba.conf
sudo maas init region+rack --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@$HOSTNAME/$MAAS_DBNAME"
echo gh:GigiaJ | sudo maas createadmin --username=$MAAS_USERNAME --email=$MAAS_EMAIL
npx hfs@latest
```
This installs node, maas, configures maas, then installs and runs hfs.

Append to ~/.hfs/config.yaml:
```
port: 8080
create-admin: password
```
This sets the port to be above 1024 (1024 and lower require root). Then it sets a password for the local admin so we can set-up from there


If your image isn't on the deploying device (it should be generally built and deployed from there) use something like rsync to get it there


Now that you have an HTTP and File server and MaaS we need to set up the HTTP File Server to be in the format MaaS expects.

MaaS expects a SimpleStream (LXD/LXC) format for images to be served to it. (https://maas.io/docs/about-standard-images)


We use the tool here to build those into our directory we set in HFS to be shared:
https://canonical-lxd-imagebuilder.readthedocs-hosted.com/en/latest/howto/install/

In which we use simplestream-maintainer from canonical themselves to build our directory

