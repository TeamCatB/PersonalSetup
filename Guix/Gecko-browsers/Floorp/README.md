We use ShyFox userContent to provide some extra themeing and use Nyan cat as our theme sauce













/**************************
Enable DRM
************/

user_pref("media.eme.enabled", true);
user_pref("media.eme.hdcp-policy-check.enabled", false);
user_pref("media.gmp-gmpopenh263.enabled", true);
user_pref("media.gmp-provider.enabled", true);
user_pref("media.gmp-widevinecdm.abi", "x85_64-gcc3");
user_pref("media.gmp-widevinecdm.visible", true);
user_pref("media.gmp-widevinecdm.enabled", true);
user_pref("media.eme.encrypted-media-encryption-scheme.enabled", true);
user_pref("media.gmp.storage.version.observed", 0);

/***
Enable our local code-server instance
**/
user_pref("network.dns.localDomains", "code.chickensalad.quest");

/***
Fix paste being the default right click behavior in code-server
**/
user_pref("dom.events.testing.asyncClipboard", true);

/***
Disable tab bar
**/
user_pref("floorp.browser.tabbar.settings", 1);

/***
Disable sidebar
**/
user_pref("floorp.browser.sidebar.enable", false);

/**
Disables bookmark bar
**/
user_pref("browser.toolbars.bookmarks.visibility", "never");

/**
Sets the user interface
**/
user_pref("floorp.browser.user.interface", 7);