;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules	(gnu)
		(guix packages)
    (gnu packages shells)
		(gnu packages xorg)
    (nongnu packages linux)
		(nongnu system linux-initrd)
   
)
(use-service-modules base  cups desktop networking ssh xorg )
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
 		  (shell (file-append zsh "/bin/zsh"))
                  (supplementary-groups '("wheel" "netdev" "audio" "video" "input")))
                %base-user-accounts))


(services
   (append (list (service xfce-desktop-service-type)
                 (service plasma-desktop-service-type)
                 (service openssh-service-type)
                 (extra-special-file "/lib64/ld-linux-x86-64.so.2" "/gnu/store/hw6g2kjayxnqi8rwpnmpraalxi0djkxc-glibc-2.39/lib/ld-linux-x86-64.so.2")
             	   (udev-rules-service 'steam-devices steam-devices-udev-rules)
                 (set-xorg-configuration
                  (xorg-configuration (keyboard-layout keyboard-layout)))
                 (service bluetooth-service-type))
           %desktop-services))

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot"))
                (menu-entries (list 
                (menu-entry
                  (label "Arch Linux")
                  (device (uuid "2755-7752" 'fat))
                  (chain-loader "/EFI/arch/grubx64.efi"))
                (menu-entry
                  (label "Windows")
                  (device (uuid "F204-F2E2" 'fat))
                  (chain-loader "/EFI/Microsoft/Boot/bootmgrw.efi"))
                ))
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
                         (mount-point "/boot")
                         (device (uuid "3621-68F9"
                                       'fat))
                         (type "vfat"))

 %base-file-systems)))
