;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu) (nongnu packages linux))
(use-service-modules base cups desktop networking ssh xorg )
(use-package-modules firmware games)

(operating-system
  (kernel linux)
  (firmware (list linux-firmware amdgpu-firmware))
  (locale "en_US.utf8")
  (timezone "America/Chicago")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "Catdog7")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "jaggar")
                  (comment "Jaggar")
                  (group "users")
                  (home-directory "/home/jaggar")
                  (supplementary-groups '("wheel" "netdev" "audio" "video" "input")))
                %base-user-accounts))

(services
   (append (list (service xfce-desktop-service-type)
                 (service plasma-desktop-service-type)
                 (service openssh-service-type)
             	 (udev-rules-service 'steam-devices steam-devices-udev-rules)
                 (set-xorg-configuration
                  (xorg-configuration (keyboard-layout keyboard-layout)))
                 (service bluetooth-service-type))
           %desktop-services))

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid
                                  "b9c6ca07-2d84-4730-8fb7-975f481bf36b"
                                  'btrfs))
                         (type "btrfs"))
			(file-system
                         (mount-point "/games")
                         (device (uuid "c3231cc4-d95f-4656-988d-24151ab48137" 
					'btrfs))
			 (type "btrfs"))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "F204-F2E2"
                                       'fat32))
                         (type "vfat")) %base-file-systems)))
