{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages.nix
      ./flakes.nix
      <home-manager/nixos>
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.cleanTmpDir = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.default = "1";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.grub.extraEntries = ''
    menuentry "Windows 10" {
      insmod part_gpt
      insmod fat
      insmod search_fs_uuid
      insmod chain
      search --fs-uuid --set=root 66D5-69F4
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';

  boot.blacklistedKernelModules = [
    "nouveau"
  ];

  boot.kernel.sysctl."kernel.pid_max" = 1048576;
  boot.kernel.sysctl."kernel.sysrq" = 1;

  networking.hostName = "io"; # Define your hostname.
  networking.networkmanager.enable = true;


  console.font = "Lat2-Terminus16";
  console.keyMap = "hu";

  i18n = {
    defaultLocale = "en_IE.UTF-8";
  };

  nixpkgs.config.pulseaudio = true;

  # managed by tzupdate
  # time.timeZone = "Europe/Budapest";

  nixpkgs.config.allowUnfree = true;

  security.polkit.enable = true;

  services.acpid.enable = true;
  services.logind.lidSwitch = "suspend";
  services.locate.enable = false;
  services.gvfs.enable = true;
  services.fstrim.enable = true;
  services.lorri.enable = true;
  services.tzupdate.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = true;
    ciphers = [
      "chacha20-poly1305@openssh.com"
      "aes256-gcm@openssh.com"
      "aes128-gcm@openssh.com"
      "aes256-ctr"
      "aes192-ctr"
      "aes128-ctr"
    ];
    forwardX11 = true;
    kexAlgorithms = [
      "curve25519-sha256@libssh.org"
      "diffie-hellman-group-exchange-sha256"
    ];
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {
    addSSL = false;
    enableACME = false;
    root = "/var/www/nginx";
    listen = [
      { addr = "127.0.0.1"; port = 80; ssl = false; }
    ];
    locations."/zsolt/".alias = "/home/zsolt/www/";
    locations."/zsolt/".index = "index.html";
  };

  services.timesyncd.enable = lib.mkDefault true;
  services.blueman.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser pkgs.brgenml1lpr pkgs.brgenml1cupswrapper ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver = {
    enable = true;

    layout = "hu";
    # xkbOptions = "eurosign:e";

    videoDrivers = [ "nvidia" ];
    # Enable touchpad support.
    libinput.enable = true;

    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager.xfce.enable = true;
    autoRepeatDelay = 250;
    autoRepeatInterval = 60;
    #    multitouch = {
    #      enable = true;
    #      invertScroll = false;
    #      additionalOptions =
    #      ''
    #      Option "FingerHigh"  "200"
    #      Option "FingerLow"   "100"
    #      '';
    #    };
  };

  programs.zsh.enable = true;
  programs.bash.enableCompletion = true;
  programs.tmux.enable = true;
  programs.adb.enable = true;
  programs.mtr.enable = true;

  programs.ssh.startAgent = true;

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  documentation.dev.enable = true;

  fonts = {
    fontDir.enable = true;
    # enableFontDir = true;
    fontconfig.enable = true;
    fonts = with pkgs; [
      corefonts
      source-code-pro
      noto-fonts
      noto-fonts-cjk
      google-fonts
      fira-code
      fira-code-symbols
      noto-fonts-emoji
      liberation_ttf
      libertine
      zilla-slab
      roboto
      roboto-mono
      roboto-slab
      montserrat
      hack-font
      work-sans
      victor-mono
      vistafonts
    ];
  };

  # Require password for sudo but does not check it
  security.pam.services.sudo.text = ''
    # Account management.
    account required pam_unix.so
    # Authentication management.
    auth sufficient pam_exec.so expose_authtok /run/current-system/sw/bin/cat
    auth required pam_deny.so
    # Password management.
    password sufficient pam_unix.so nullok sha512
    # Session management.
    session required pam_env.so envfile=/etc/pam/environment
    session required pam_unix.so
  '';

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zsolt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "docker" "dialout" "libvirtd" ];
    useDefaultShell = true;
  };

  home-manager.users.zsolt = { pkgs, ... }: {
    home.packages = [ pkgs.httpie ];
    home.stateVersion = "22.11";
  };
  home-manager.useGlobalPkgs = true;

  nix = {
    gc.automatic = true;
    settings.sandbox = true;
  };

  nixpkgs.overlays = [
    (self: super: {
      intel-ocl = super.intel-ocl.overrideAttrs
        (old: {
          src = pkgs.fetchzip {
            url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/11396/SRB5.0_linux64.zip";
            sha256 = "0qbp63l74s0i80ysh9ya8x7r79xkddbbz4378nms9i7a0kprg9p2";
            stripRoot = false;
          };
        });
    }
    )
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
