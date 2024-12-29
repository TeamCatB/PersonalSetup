So Foundry provides a VTT which we serve through Caddy after we build it using Docker. It has been configured to have a tidy auto-downloader script once you've provided your credentials for the site through a series of simplistic curl commands.
From there the software is downloaded as a zip and then unzipped and the command to execute on run is the main.js file in the directory.

TODO:
THIS MAY REQUIRE THE LICENSE ACTIVATION TO BE ADDED
I DID NOT TEST FROM ZERO TO FULLY FUNCTIONAL. ONLY FROM ZERO TO DOCKER BUILD COMPLETION (meaning it was downloaded and unzipped)
Such a step would be short however


To build:
dockerfile build -f Dockerfile -t foundryvtt .

To run:
docker run -d -v /deploy/personal/vtt12/data:/root/.local/share/FoundryVTT -p 30000:30000 foundryvtt