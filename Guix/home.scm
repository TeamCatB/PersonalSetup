(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
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
        (service home-files-service-type
         `((".guile" ,%default-dotguile)
           (".Xdefaults" ,%default-xdefaults)))
        (service home-xdg-configuration-files-service-type
         `(("gdb/gdbinit" ,%default-gdbinit)
           ("nano/nanorc" ,%default-nanorc)))
        (simple-service 'custom-dbus-services home-dbus-service-type (map specification->package (list "xdg-desktop-portal-kde" "xdg-desktop-portal"))))))
