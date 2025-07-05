;;; Core GNU modules and system definitions
(use-modules (gnu))

;;; Package definitions
(use-modules	
             ((gnu packages shells) #:select (zsh))
             ((gnu packages gnome) #:select (network-manager-openvpn))
             ((gnu packages linux) #:select (v4l2loopback-linux-module))
 ((gnu packages games) #:select (steam-devices-udev-rules)))

;;; Service definitions
(use-modules
             ((gnu services docker) #:select (containerd-service-type docker-service-type))
 ((gnu services desktop) #:select (gnome-desktop-service-type bluetooth-service-type %desktop-services))
             ((gnu services xorg) #:select (gdm-service-type))
             ((gnu services ssh) #:select (openssh-service-type))
 ((gnu services networking) #:select (network-manager-service-type network-manager-configuration)))

;;; Third-party and non-free modules
(use-modules
             (gchannel packages xdg-desktop-portal-hyprland-input-capture)
 ((nongnu packages linux) #:select (linux linux-firmware amdgpu-firmware)))

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
	   (swap-space (target (uuid "cd232ce0-e15a-4df9-a6e0-0ac23f42eae8")))))

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "jaggar")
                  (comment "Jaggar")
                  (group "users")
                  (home-directory "/home/jaggar")
 		  (shell (file-append zsh "/bin/zsh"))
                  (supplementary-groups '("docker" "wheel" "netdev" "audio" "video" "input")))
                %base-user-accounts))
  (packages
    (append
     (map specification->package '( "hyprland-input-capture"))
      %base-packages))

(services
 (cons*
                 (service mysql-service-type)
                 (service containerd-service-type)
                 (service docker-service-type)
                 (service openssh-service-type)
  (service bluetooth-service-type)
  ;; Add udev rules for Steam controllers and other hardware.
             	   (udev-rules-service 'steam-devices steam-devices-udev-rules)
  ;; Raise the open file descriptor limits. This prevents errors in applications
  ;; that need to open many files, such as database servers or games running
  ;; through Wine/Proton.
  (service pam-limits-service-type
          (list
          (pam-limits-entry "*" 'soft 'nofile 65536)
          (pam-limits-entry "*" 'hard 'nofile 262144)))
  ;; Modify the default desktop services to add OpenVPN support
  ;; directly into NetworkManager.
  ;; Otherwise we can't use our VPN config files.
                 (modify-services %desktop-services
                 (network-manager-service-type config =>
                 (network-manager-configuration
                  (inherit config)
       (vpn-plugins (list network-manager-openvpn)))))))

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot"))
              ;; Add chain-loader entries for other operating systems
              ;; installed on this machine.
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

  (file-systems (cons* 
                      ;; BTRFS root partition on the main NVMe drive. 
                       (file-system
                         (mount-point "/")
                        (device (uuid "b9c6ca07-2d84-4730-8fb7-975f481bf36b"
                                  'btrfs))
                         (type "btrfs"))
                      ;; Separate BTRFS partition on a secondary drive for games.
			(file-system
                         (mount-point "/games")
                         (device (uuid "c3231cc4-d95f-4656-988d-24151ab48137" 
					'btrfs))
			 (type "btrfs"))
                      ;; Standard EFI boot partition.
(file-system
                         (mount-point "/boot")
                        (device (uuid "3621-68F9" 'fat))
                         (type "vfat"))
                       %base-file-systems)))
