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

(define %desktop-packages
 (append
  (specifications->packages
  '(
  ;; "v4l2loopback-linux-module"
  "xdg-desktop-portal" ;;actual package
  "xdg-desktop-portal-wlr" ;;backend
  "xdg-desktop-portal-kde" ;;backend
  "dbus"
  "pipewire"
  "wireplumber"
  "font-google-noto"
  "font-google-noto-serif-cjk"
  "font-google-noto-sans-cjk"
  "font-google-noto-emoji"
  "font-nerd-fonts"
  "gnome-themes-extra"
  "dpkg"
  "zsh"
  "zlib"
  "sdl2"
  "nss"
  "fmt"
  "ffmpeg"
  "strace"
  "xhost"
  "xauth"
  "bluez"
  "btrfs-progs"
  "amdgpu-firmware"
  "mediatek-firmware"
  "egl-wayland"
  "procps"
  "pkg-config"
  "wayland"
  "xcb-util"
  "xinit"
  "xorg-server"
  "xf86-input-libinput"
  "xf86-video-fbdev"
  "xf86-video-nouveau"
  "network-manager-openvpn"
  "libglvnd"
  "libp11"
  "libx11"
  "libxcb"
  "libxxf86vm"
  "libsm"
  "gtkmm"
  "gtk"
  "gdm"
  "gdk-pixbuf"
  "hicolor-icon-theme"
  "libglvnd"
  "sddm"
  ))))

(define (code-server-service config)
  (list
    (shepherd-service
      (documentation "Run code-server")
      (provision '(code-server))
      (modules '((shepherd support)))
      (start #~(make-forkexec-constructor
        (list #$(file-append 
          (specification->package "code-server")
          "/bin/code-server"))
            #:log-file (string-append %user-log-dir "/code-server.log")))
      (stop #~(make-kill-destructor))
      (respawn? #t))))

(define home-code-server-service-type
  (service-type 
    (name 'code-server)
    (extensions (list (service-extension home-shepherd-service-type code-server-service)))
    (default-value "code-server")
    (description "code-server service")))

(home-environment
  (packages
  (append
   %dev-packages
   %program-packages
   %desktop-packages
  ))
  (services
    (list
      (service home-zsh-service-type)
      (service home-pipewire-service-type)
      (service home-code-server-service-type)
      (service home-files-service-type
        `((".guile" ,%default-dotguile)
          (".Xdefaults" ,%default-xdefaults)))
      (service home-xdg-configuration-files-service-type
        `(("gdb/gdbinit" ,%default-gdbinit)
          ("nano/nanorc" ,%default-nanorc)))
      (simple-service 'custom-dbus-services home-dbus-service-type (map specification->package (list "xdg-desktop-portal-kde" "xdg-desktop-portal")))
      (simple-service 'extra-environment-variables home-environment-variables-service-type   
  `(("GUIX_SANDBOX_EXTRA_SHARES" . "/games")
    ("QT_QPA_PLATFORM" . "xcb")))
))
)
