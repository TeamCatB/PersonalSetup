Gecko-based browsers can be configured in manners similar to Firefox (for obvious reasons).

So to create the styling that I enjoy using there are a few steps needed in advance.

In the browser itself navigate to about:config in the URL bar
Hit Accept on the screen that pops up
Search for toolkit.legacyUserProfileCustomizations.stylesheets
Change it to true

This allows Firefox to recognize userChrome.css files (which can override any defaults Gecko-based browsers use)


Now we need to create a userChrome.css
https://www.userchrome.org

I've included mine, but to shape the changes you want some helpful tips are using Firefox itself and then hitting (Ctrl+Alt+Shift+I)

Just after you hit Ctrl+Alt+Shift+I it'll ask to allow incoming connections for remote debugging. Hit ok and you'll be greeted with a likely familiar interface. This is like the developer console, but for the browser itself. Some Gecko-based won't have this enabled (Mullvad) so using raw Firefox is preferable.
This can let you see the stylesheets currently loaded for the browser and modify them (or modify your userChrome.css on the fly and it will be reloaded in real time).)
https://firefox-source-docs.mozilla.org/devtools-user/browser_toolbox/index.html


Then depending on what Gecko-based browser you use you'll need to navigate to the hidden dot folder (for Firefox on Linux and Mullvad it is .mozilla and .mullvadbrowser respectively)

Navigate to the browser (can be the browsers name) folder and the profile that corresponds to your user and make a new folder named chrome
Place the userChrome.css file in there


Restart the browser and the changes will have taken effect.