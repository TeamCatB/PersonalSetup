(use-modules	
    (gnu)
    (gnu packages shells)
    (gnu packages gnome)
    (gnu packages linux)
    (nongnu packages linux)
    (nongnu system linux-initrd)
   
)

(use-package-modules firmware games)
(use-service-modules cups docker desktop sddm databases networking ssh xorg )

(operating-system
  (kernel linux)
  (firmware (list linux-firmware amdgpu-firmware))
  (locale "en_US.utf8")
  (timezone "America/Chicago")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "Catdog7")

  (kernel-loadable-modules (list v4l2loopback-linux-module))

(swap-devices
 (list
			 (swap-space (target (uuid "cd232ce0-e15a-4df9-a6e0-0ac23f42eae8")))
))

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "jaggar")
                  (comment "Jaggar")
                  (group "users")
                  (home-directory "/home/jaggar")
 		  (shell (file-append zsh "/bin/zsh"))
                  (supplementary-groups '("docker" "wheel" "netdev" "audio" "video" "input")))
                %base-user-accounts))

(services
 (cons*
                 (service mysql-service-type)
                 (service containerd-service-type)
                 (service docker-service-type)
                 (service plasma-desktop-service-type)
                 (service gnome-desktop-service-type)
                 (service openssh-service-type)
                 (extra-special-file "/lib64/ld-linux-x86-64.so.2" "/gnu/store/hw6g2kjayxnqi8rwpnmpraalxi0djkxc-glibc-2.39/lib/ld-linux-x86-64.so.2")
             	   (udev-rules-service 'steam-devices steam-devices-udev-rules)
                 (set-xorg-configuration (xorg-configuration (keyboard-layout keyboard-layout)))
                 (service bluetooth-service-type))
                 (modify-services %desktop-services
                 (network-manager-service-type config =>
                 (network-manager-configuration
                  (inherit config)
       (vpn-plugins (list network-manager-openvpn)))))))

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot"))
                (menu-entries (list
		(menu-entry
		  (label "GParted")
		  (device (uuid "2025-01-30-22-09-48-00" 'iso9660))
		  (chain-loader "/EFI/boot/grubx64.efi"))
                (menu-entry
                  (label "Arch Linux")
                  (device (uuid "2755-7752" 'fat))
                  (chain-loader "/EFI/arch/grubx64.efi"))
                (menu-entry
                  (label "Windows")
                  (device (uuid "F204-F2E2" 'fat))
                               (chain-loader "/EFI/Microsoft/Boot/bootmgrw.efi"))))
                (keyboard-layout keyboard-layout)))

  (file-systems (cons* (file-system
                         (mount-point "/")
                        (device (uuid "b9c6ca07-2d84-4730-8fb7-975f481bf36b"
                                  'btrfs))
                         (type "btrfs"))
			(file-system
                         (mount-point "/games")
                         (device (uuid "c3231cc4-d95f-4656-988d-24151ab48137" 
					'btrfs))
			 (type "btrfs"))
(file-system
                         (mount-point "/boot")
                        (device (uuid "3621-68F9" 'fat))
                         (type "vfat"))
                       %base-file-systems)))
