(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu home services shepherd)
             (gnu home services sound)
             (gnu home services desktop)
             (gnu packages)
             (gnu services)
             (gnu system)
             (gnu system shadow)
             (nongnu packages)
             (guix gexp))

(define %dev-packages
  (specifications->packages
    '(
    "clojure"         ;; A dynamic, general-purpose programming language, combining the approachability and interactive development of a scripting language with an efficient and robust infrastructure for multithreaded programming.
    "openjdk:jdk"     ;; The Java Development Kit, an implementation of the Java Platform, Standard Edition.
    "leiningen"       ;; A build automation and dependency management tool for the Clojure programming language.
    "valgrind"        ;; An instrumentation framework for building dynamic analysis tools that can be used to automatically detect memory management and threading bugs, and to profile your programs in detail.
    "gdb"             ;; The GNU Debugger, which allows you to see what is going on inside another program while it executes.
    "gcc-toolchain"   ;; The GNU Compiler Collection toolchain, which includes a set of programming language compilers.
    "git"             ;; A free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency.
    "strace"          ;; A diagnostic, debugging, and instructional userspace utility for Linux to monitor system calls and signals.
    "runc"            ;; A CLI tool for spawning and running containers according to the OCI specification.
  )))
  
(define %program-packages
  (specifications->packages
  '(
    "deskflow"                ;; A productivity application designed to help you manage your tasks and workflows.
    "librewolf"               ;; An independent fork of Firefox, with the primary goals of privacy, security, and user freedom.
    "floorp"                  ;; A fork of Firefox that is more customizable and has more features than the original. It has PWAs baked in.
    "steam"                   ;; A video game digital distribution service by Valve.
    "neovim"                  ;; A hyperextensible, Vim-based text editor that’s backwards-compatible with Vim. We combo it with the extension in code-server/vscode.
    "vscodium"                ;; A community-driven, freely-licensed binary distribution of Microsoft’s Visual Studio Code.
    "microsoft-edge-stable"   ;; The stable release of Microsoft's Edge web browser.
    "bolt-launcher"           ;; A third-party launcher for Jagex accounts for the popular online game RuneScape and Old School RuneScape.
    "obs"                     ;; Open Broadcaster Software, a free and open-source software for video recording and live streaming.
    "obs-droidcam"            ;; A plugin for OBS Studio that lets you use your phone as a camera source.
    "flatpak"                 ;; A system for building, distributing, and running sandboxed desktop applications on Linux.
    "openscad"                ;; A software for creating solid 3D CAD objects.
    "conky"                   ;; A free, light-weight system monitor for X, that displays any kind of information on your desktop.
    "code-server"             ;; A service that allows you to run VS Code on any machine anywhere and access it in the browser.
  )))

(define %utility-packages
  (append
   (specifications->packages
   '(
  "fmt"                     ;; A modern formatting library for C++, providing a fast and safe alternative to C-style printf.
  "ffmpeg"                  ;; A complete, cross-platform solution to record, convert and stream audio and video.
  "dpkg"                    ;; The package manager for Debian-based systems; handles installation, removal, and management of .deb packages.
  "pkg-config"              ;; A helper tool used when compiling applications and libraries to retrieve information about installed libraries.
  "util-linux"              ;; A standard package of essential Linux command-line utilities.
  "btrfs-progs"             ;; A set of userspace utilities for managing Btrfs filesystems.
   ))))

(define %lib-packages
  (append
   (specifications->packages
   '(
  "libglvnd"                ;; The GL Vendor-Neutral Dispatch library, which allows multiple OpenGL implementations to coexist on the same system.
  "libp11"                  ;; A library that provides a higher-level interface for PKCS#11, simplifying interaction with cryptographic hardware.
  "libx11"                  ;; The core X11 client library, providing the fundamental functions for interacting with an X server.
  "libxcb"                  ;; The X C Binding, a replacement for Xlib that provides a more modern and efficient way to communicate with the X server.
  "libxxf86vm"              ;; The XFree86-VidModeExtension library, allowing for the manipulation of video modes.
  "libsm"                   ;; The X Session Management library.
  "zlib"                    ;; A software library used for data compression and decompression.
  "sdl2"                    ;; A cross-platform development library providing low-level access to audio, keyboard, mouse, joystick, and graphics hardware.
  "nss"                     ;; Network Security Services, a set of libraries designed to support cross-platform development of security-enabled client and server applications.
  "egl-wayland"             ;; A library that allows EGL (a Khronos rendering API) to work with the Wayland display protocol.   
  "libappindicator"         ;; A library that allows applications to export a menu to the system tray.
  "libdbusmenu-qt"          ;; A Qt implementation for libdbusmenu, allowing Qt applications to create D-Bus menus.
  "procps"                  ;; A set of command-line and full-screen utilities that provide information out of the /proc filesystem, including `ps`, `top`, and `kill`.
  "libnotify"               ;; A library for sending desktop notifications to a notification daemon.
))))

(define %general-packages
  (append
   (specifications->packages
   '(
  "gdm"                     ;; The GNOME Display Manager, which provides graphical logins and manages display servers.
  "sddm"                    ;; The Simple Desktop Display Manager, a modern display manager for X11 and Wayland.
  "xhost"                   ;; A server access control program for X; it adds and deletes hostnames or user names to the list allowed to make connections to the X server.
  "xauth"                   ;; A utility for managing X authority files, which contain authentication information for connecting to an X server.
  "xinit"                   ;; A program that allows a user to manually start an Xorg display server.
  "xcb-util"                ;; A collection of utility libraries for the X C Binding (XCB), making it easier to work with.
  "xorg-server"             ;; The core X Window System display server.
  "wayland"                 ;; A communication protocol that specifies the communication between a display server and its clients.
  "amdgpu-firmware"         ;; Firmware files required for AMD Radeon graphics cards to function correctly.
  "mediatek-firmware"       ;; Firmware files for various MediaTek wireless and Bluetooth devices.
  "xf86-input-libinput"     ;; An X.Org driver that uses the libinput library to provide generic input device support.
  "xf86-video-fbdev"        ;; An X.Org driver for framebuffer devices, providing a basic video driver.
  "xf86-video-nouveau"      ;; An open-source X.Org driver for NVIDIA graphics cards.
  "gtkmm"                   ;; The official C++ interface for the popular GUI library GTK.
  "gtk"                     ;; The GIMP Toolkit, a multi-platform toolkit for creating graphical user interfaces.
  "gdk-pixbuf"              ;; A toolkit for image loading and pixel buffer manipulation, often used with GTK.
  "bluez"                   ;; The official Linux Bluetooth protocol stack; it provides the core Bluetooth functionality.
   ))))

(define %desktop-packages
 (append
  (specifications->packages
  '(
  "hicolor-icon-theme"      ;; A fallback icon theme that provides a standard directory structure for icon themes.
  "gnome-themes-extra"      ;; Provides extra themes for the GNOME desktop, including the popular Adwaita-dark.
  "zsh"                     ;; An extended Bourne shell (sh) with many improvements, including more powerful interactive features.
  "network-manager-openvpn" ;; A plugin for NetworkManager to support OpenVPN connections.
  "waybar"                  ;; Provides a highly customizable Wayland bar for Sway and other wlroots-based compositors.
  "swaynotificationcenter"  ;; A simple notification daemon for Sway/Wayland that displays notifications.
  "hyprland-protocols-input-capture" ;; On input capture merge this can be reverted to hyprland-protocols
  "hyprutils"               ;; Utility library used across the Hyprland ecosystem.
  "hyprwayland-scanner"     ;; An implementation of wayland-scanner tailored for Hyprland.
  "hyprlang"                ;; Configuration language parser for Hyprland, enabling the config file to be parsed and used.
  "hyprlock"                ;; The official lock screen utility for the Hyprland compositor.
  "wayland-protocols"       ;; A set of standard protocols for the Wayland display server system.
  "wl-clipboard"            ;; Provides command-line copy and paste utilities for Wayland.
  "mako"                    ;; A lightweight notification daemon for Wayland.
  "blueman"                 ;; A full-featured Bluetooth manager that provides a graphical interface for managing Bluetooth devices.
  "pavucontrol"             ;; A simple GTK-based volume control tool ("mixer") for PulseAudio.
  "nnn"                     ;; A fast and resource-sensitive terminal file manager.
  "wofi"                    ;; A launcher/menu program for wlroots-based Wayland compositors like Sway.
  "xdg-desktop-portal"      ;; A framework that allows sandboxed applications to access resources outside their sandbox.
  "xdg-desktop-portal-hyprland-input-capture" ;; Used to connect hyprland to the xdg-desktop-portal itself and declares certain privileges 'portals'. Should be reverted to just xdg-desktop-portal-hyprland when input-capture is merged.
  "slurp"                   ;; A command-line utility to select a region on a Wayland desktop.
  "grim"                    ;; A command-line screenshot tool for Wayland compositors.
  "xcb-util-cursor"         ;; A utility library for the XCB library, providing convenience functions for cursor management.
  "dbus"                    ;; A message bus system, providing an easy way for applications to talk to one another.
  "pipewire"                ;; A server and user space API to deal with multimedia pipelines.
  "wireplumber"             ;; A session and policy manager for PipeWire.
  "font-google-noto"        ;; The base Noto font family, designed for visual harmony across languages.
  "font-google-noto-serif-cjk" ;; Serif variant of Noto for Chinese, Japanese, and Korean scripts.
  "font-google-noto-sans-cjk" ;; Sans-serif variant of Noto for CJK scripts.
  "font-google-noto-emoji"  ;; The emoji font from the Noto family, providing full-color emoji support.
  "font-nerd-fonts"         ;; A collection of patched fonts with icons (Devicons, Font Awesome, etc.) for use in terminals and status bars.
  ))))

(define (wayland-hyprland-env-shepherd-service config)
  ;; This procedure defines a Shepherd service that is meant to be controlled manually.
  ;; Its purpose is to inject Wayland and Hyprland session variables into the
  ;; Shepherd daemon's environment, making them available to other services.
  (list
   (shepherd-service
    (documentation "Sets WAYLAND_DISPLAY and HYPRLAND_INSTANCE_SIGNATURE to arguments
passed in. This should be called from a wayland compositor: herd start
wayland-display $WAYLAND_DISPLAY $HYPRLAND_INSTANCE_SIGNATURE")

    ;; Provides the necessary environment or scripts for the service to function.
    (provision '(wayland-hyprland-env))

    ;; The service should not start automatically or respawn, as it's triggered
    ;; manually by the user's graphical session startup script.
    (auto-start? #f)
    (respawn? #f)

    ;; The start action is a procedure that accepts two arguments from the 'herd start'
    ;; command and uses them to set the environment variables.
    (start #~(lambda (wayland-display hyprland-sign)
               (setenv "WAYLAND_DISPLAY" wayland-display)
               (setenv "HYPRLAND_INSTANCE_SIGNATURE" hyprland-sign)))

    ;; The stop action cleans up the environment by unsetting the variables.
    (stop #~(lambda _
              (unsetenv "WAYLAND_DISPLAY")
              (unsetenv "HYPRLAND_INSTANCE_SIGNATURE")
              #f)))))

(define-public home-wayland-hyprland-env-service-type
  ;; Defines the public interface that users will interact with in their home-environment records.
  ;; This pattern abstracts the underlying Shepherd service implementation.
  (service-type
   (name 'home-wayland-hyprland-env)
   (description "A service to set WAYLAND_DISPLAY and HYPRLAND_INSTANCE_SIGNATURE for
shepherd services.")

   ;; The service is disabled by default; users must explicitly enable it.
   (default-value #f)

   ;; This is how the service integrates with the system. It extends the main
   ;; user-level Shepherd service by adding our custom service to it.
   (extensions
    (list (service-extension home-shepherd-service-type
                             wayland-hyprland-env-shepherd-service)))))

(define (code-server-service config)
  ;; This procedure defines a Shepherd service to run and manage code-server,
  ;; which provides a web-based instance of VS Code. The service ensures
  ;; code-server starts automatically and restarts if it crashes.
  (list
    (shepherd-service
      (documentation "Run the code-server backend.")
      (provision '(code-server)) ;; Ensure the code-server package is available.
      (modules '((shepherd support)))

      ;; Start the service by directly executing the binary from its package path.
      ;; All output is redirected to a dedicated log file in the user's home directory.
      (start #~(make-forkexec-constructor
                (list #$(file-append (specification->package "code-server") "/bin/code-server"))
                #:log-file (string-append %user-log-dir "/code-server.log")))

      ;; To stop the service, simply send a kill signal to the process.
      (stop #~(make-kill-destructor))

      ;; Automatically respawn the service if it terminates unexpectedly.
      (respawn? #t))))

(define home-code-server-service-type
  (service-type
   (name 'code-server)
   ;; This links our custom 'code-server-service' implementation to the main user Shepherd service.
   (extensions (list (service-extension home-shepherd-service-type code-server-service)))
   ;; The #t default value means the service will be active unless explicitly disabled.
   (default-value #t)
   (description "A user service to run a VS Code instance in the browser.")))


(home-environment
  ;; The 'packages' field aggregates all previously defined lists of software
  ;; to be installed in our profile.
  (packages
   (append
    %dev-packages
    %program-packages
    %desktop-packages
    %utility-packages
    %lib-packages
    %general-packages
  ))

  ;; The 'services' field configures the background services and system settings
  ;; that will be managed by Guix Home.
  (services
   (list
    ;; Essential system services for modern desktop environments.
    (service home-dbus-service-type)
    (service home-pipewire-service-type)

    ;; Activates the custom code-server service defined above.
    (service home-code-server-service-type)

    ;; Manages dotfiles in the user's home directory.
    (service home-files-service-type
             `((".guile" ,%default-dotguile)
               (".Xdefaults" ,%default-xdefaults)))

    ;; Manages configuration files located in '~/.config'.
    (service home-xdg-configuration-files-service-type
             `(("gdb/gdbinit" ,%default-gdbinit)
               ("nano/nanorc" ,%default-nanorc)))

    ;; Extends the sandbox for Guix commands to include an additional directory,
    ;; useful for accessing files outside the standard home paths.
    ;; In this particular case, GUIX_SANDBOX_EXTRA_SHARES is needed for Steam to recognize
    ;; external drives correctly as it is a sandboxed application.
    (simple-service 'extra-environment-variables home-environment-variables-service-type
                    `(("GUIX_SANDBOX_EXTRA_SHARES" . "/games"))))))
