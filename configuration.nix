# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let

  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz;

in

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-26.05/";


  ###########
  # Imports #
  ###########

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      ./dual-boot.nix
    ];


  ##############
  # Bootloader #
  ##############

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
    efi.canTouchEfiVariables = true;
  };


  ##############
  # Networking #
  ##############

  networking.hostName = "gandalf"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;


  ################
  # Localization #
  ################

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };


  #########
  # Users #
  #########

  security.sudo = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
    extraConfig = with pkgs; ''
      Defaults targetpw
    '';
    extraRules = [{
      groups = [ "wheel" ];
      commands = [
        {
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
        }
      ];
    }];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mathcrafted = {
    isNormalUser = true;
    description = "mathcrafted";
    extraGroups = [ "networkmanager" "wheel" "seat" ];
    packages = with pkgs; [];
  };

  home-manager.users.mathcrafted = { pkgs, ... }: {
    home.stateVersion = "26.05";
    
    programs.bash.enable = true;
    programs.kitty.enable = true;
    wayland.windowManager.hyprland.enable = true;
  };


  ############
  # Packages #
  ############

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    
    # CLI
    vim
    neovim
    git
    wget
    fastfetch
    sl
    bonsai
    cmatrix
    cowsay
    lolcat

    # Shell Layer
    tofi
    ashell
    dunst
    quickshell
    nerd-fonts.noto

    # GUI
    superfile
    kitty
    neovide
    firefox
    gparted
    mission-center

  ];


  ##############
  # Pkg Config #
  ##############

  programs.hyprland = {
    enable = true;
    withUWSM = false; # UWSM not working, don't know why
  };

  programs.uwsm.enable = false;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = false;
    configure = {
      customRC = ''
	set number
	set relativenumber
      '';
      packages.myPlugins = with pkgs.vimPlugins; {
        start = [ vim-nix ];
        opt = [];
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  ############
  # Services #
  ############

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings.main.capslock = "escape";
        settings.main.escape = "capslock";
      };
    };
  };

  services.displayManager.lemurs = {
    enable = true;
    #settings = "";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  ##############
  # OS Version #
  ##############

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
