;; This is a sample Guix Home configuration which can help setup your
;; home directory in the same declarative manner as Guix System.
;; For more information, see the Home Configuration section of the manual.
(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu packages)
             (gnu services)
             (gnu system)
             (gnu system shadow)
             (nongnu packages)
             (gnu packages base)
             (gnu packages commencement)
             (nongnu packages clojure)
             (gnu packages compression)
             (gnu packages debian)
             (gnu packages nss)
             (gnu packages package-management)
             (gnu packages version-control)
             ;;(gnu packages xdisorg)           ;; For X packages
             (gnu packages xorg)
             (gnu packages web)
             (gnu packages ssh)
             (gnu packages shells)
             (gnu packages gcc)
             (gnu packages gnome)
             (gnu packages gtk)
             (gnu packages gdb)
             (gnu packages glib)
             (gnu packages gl)
             (gnu packages librewolf)
             (gnu packages linux)
             (gnu packages sdl)
             (gnu packages pretty-print)
             (gnu packages java)
             (gnu packages databases)
             (gnu packages valgrind)
             (gnu packages video)
             (gnu packages vulkan)
             (nongnu packages mozilla)
             (nongnu packages game-client)
             (nongnu packages editors)
             (gchannel packages vivaldi)
             (gchannel packages bolt-launcher)
             (gchannel packages edge)
             (guix gexp))


(define home-config
  (home-environment
  (packages
  (list
   librewolf
   steam
   vscodium
   git
   zsh
   gdk-pixbuf
   gcc-toolchain
   leiningen
   hicolor-icon-theme
   gtk
   gtkmm
   gdb
   flatpak
   dpkg
   valgrind
   zlib
   sdl2
   pipewire
   openjdk
   nss
   libglvnd
   fmt
   ffmpeg
   strace
   xhost
   xauth
   microsoft-edge-stable
   bolt-launcher 
  ))
    (services
      (list
        ;; Uncomment the shell you wish to use for your user:
        ;(service home-bash-service-type)
        ;(service home-fish-service-type)
        (service home-zsh-service-type)

        (service home-files-service-type
         `((".guile" ,%default-dotguile)
           (".Xdefaults" ,%default-xdefaults)))

        (service home-xdg-configuration-files-service-type
         `(("gdb/gdbinit" ,%default-gdbinit)
           ("nano/nanorc" ,%default-nanorc)))))))

home-config