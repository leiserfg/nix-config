{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.bluetooth.enable = true;

  hardware.cpu.amd.updateMicrocode = true;
  # Use the systemd-boot EFI boot loader.
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # nixpkgs.overlays = [
  #     (self: super:  {
  #      linuxPackages = super.linuxPackages.extend( lpself: lpsuper: {
  #        hid-nintendo = super.linuxPackages.hid-nintendo.overrideAttrs (
  #           old: rec {
  #              src = pkgs.fetchFromGitHub {
  #              owner = "leiserfg";
  #              repo = "dkms-hid-nintendo";
  #              rev = "e7fbb49";
  #              sha256 = "sha256-xM75sDHINgiFCJgqdYduXd/oBpVnnxYy8dNDv41IVRo=";
  #              };
  #           }
  #       );
  #        }
  #              );
  #  })];
  #   boot.kernelModules = [ "hid_nintendo" ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "k10temp"];

  networking.hostName = "shiralad"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # networking.interfaces.enp37s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.xserver.displayManager = {
    lightdm.enable = true;
    # lightdm.greeters.tiny.enable=true;
    # gdm.enable = true;
    # defaultSession = "none+dot-xsession";
    # defaultSession = "none+tinywm";
  };

  services.xserver.windowManager.tinywm.enable = true;

  sound.enable = true;

  users.users.leiserfg = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "input"];
    shell = pkgs.fish;
  };

  nix.trustedUsers = ["@wheel"];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #   wget
    # firefox
    # kitty
    # yadm
    # git
    # joycond
    nfs-utils
  ];

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.steam-hardware.enable = true;
  hardware.logitech.wireless.enable = true;
  services.udev.packages = with pkgs; [logitech-udev-rules];

  #  services.udev.extraRules = ''
  # # Nintendo Switch Pro Controller over USB hidraw
  # # KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666"
  # #
  # # # Nintendo Switch Pro Controller over bluetooth hidraw
  # # KERNEL=="hidraw*", KERNELS=="*057E:2009*", MODE="0666"
  #   '';

  services.autofs = {
    enable = true;
    autoMaster = ''
      /net -hosts  --timeout=60
    '';
  };
  services.gvfs.enable = true;
  services.ananicy.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.fish.enable = true;
  programs.gamemode.enable = true;

  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.chrony.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
  # services.dbus.packages = with pkgs; [ dconf ];
  programs.dconf.enable = true;

  services.rpcbind.enable = true;

  services.interception-tools = let
    intercept = "${pkgs.interception-tools}/bin/intercept";
    caps2esc = "${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc";
    uinput = "${pkgs.interception-tools}/bin/uinput";
  in {
    enable = true;
    udevmonConfig = ''
      - JOB: ""
        DEVICE:
          NAME: .*[Ff]erris.*
      - JOB: "${intercept} -g $DEVNODE | ${caps2esc} -m 2 | ${uinput} -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };
  # services.joycond.enable = true;
}
