We use a Dockerfile to build the image

After installing FoundryVTT go to the program files directory. On Linux it'll be installed via WINE and so it'll be somewhere like:
/home/USER/.wine/drive_c/Program Files/Foundry Virtual Tabletop/resources/
We need the /app directory inside here


With that we include that in our dockerbuild via copy and then execute the main.js file in the directory inside the container with Node





Can probably make an auto-updater with Docker if you're feeling creative. Could check for the latest version. Could curl the download link with creds (in a .env file or something) and then run the installer in WINE. Then could just run the normal install process inside Docker w/o needing a copy command.
