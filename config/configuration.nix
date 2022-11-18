{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages.nix
      ./flakes.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.cleanTmpDir = true;

  boot.kernel.sysctl."kernel.pid_max" = 1048576;
  boot.kernel.sysctl."kernel.sysrq" = 1;

  networking.hostName = "skylake"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  console.font = "Lat2-Terminus16";
  console.keyMap = "hu";

  i18n = {
    defaultLocale = "en_IE.UTF-8";
  };

  nixpkgs.config.pulseaudio = true;

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


  services.timesyncd.enable = lib.mkDefault true;
  services.blueman.enable = true;

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
    useGlamor = true;

    layout = "hu";
    # xkbOptions = "eurosign:e";

    videoDrivers = [ "modesetting" ];
    # Enable touchpad support.
    libinput.enable = true;

    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager.xfce.enable = true;
    autoRepeatDelay = 250;
    autoRepeatInterval = 60;
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

  nix = {
    gc.automatic = true;
    settings.sandbox = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.05"; # Did you read the comment?

}
