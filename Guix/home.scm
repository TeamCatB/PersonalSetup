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
    "clojure"
    "openjdk:jdk"
    "leiningen"
    "valgrind"
    "gdb"
    "gcc-toolchain"
    "git"
  )))
  
(define %program-packages
  (specifications->packages
  '(
    "librewolf"
    "steam"
    "vscodium"
    "microsoft-edge-stable"
    "bolt-launcher"
    "obs"
    "obs-droidcam"
    "flatpak"
    "openscad"
    "cura"
    "conky"
    "code-server"
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
  "wayland"
  "xinit"
  "xorg-server"
  "xf86-input-libinput"
  "xf86-video-fbdev"
  "xf86-video-nouveau"
  "network-manager-openvpn"
  "libglvnd"
  "libx11"
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
          "/bin/code-server")
          "--cert")
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
        (simple-service 'custom-dbus-services home-dbus-service-type (map specification->package (list "xdg-desktop-portal-kde" "xdg-desktop-portal"))))))
