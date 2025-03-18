So steam expects an exported share
but it also expects explicitly steamapps to be at the root of that dir

you can not pass /games/SteamLibrary
you must instead create a symlink and then place that symlink at the root




Add your user to the input group






export GUIX_SANDBOX_EXTRA_SHARES="/games" 
steam

Setting up a kdewallet is generally helpful on install. Should see if we can automate that or something.



KDE needs the splash screen disabled or it loads *REALLY* slow (30s or so)


extensionKind in VS Code (search the setting in the settings section) can be used to stop some extensions from trying to run on the local