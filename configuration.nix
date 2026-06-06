# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

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


  ###############
  # Environment #
  ###############


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
    programs.firefox.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      settings = {

	############
        # PROGRAMS #
        ############
	search._var = "tofi-drun --drun-launch=true"; # Search command
	terminal._var = "kitty"; # Terminal command
	filesGUI._var = "dolphin"; # Graphical file explorer command
	filesTUI._var = "kitty -o confirm_os_window_close=0 superfile"; # Text file explorer command
	toolbar._var = "ashell"; # Toolbar command
        
	#############
        # AUTOSTART #
	#############
        on._args = [
	  "hyprland.start"
	  (lib.generators.mkLuaInline "function()\nhl.exec_cmd(toolbar)\nend")
	];

	############
        # KEYBINDS #
        ############
        
	mainMod._var = "SUPER";
	bind = [
	# Miscellaneous keybinds
	  # Open search with mainMod + Space
	  {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + SPACE\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(search)") ];}
	  
          # Close window with mainMod + C
	  {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + C\"") (lib.generators.mkLuaInline "hl.dsp.window.close()") ];}
	  
	  # Open terminal with mainMod + R
	  {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + R\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(terminal)") ];}
	  
	  # Close hyprland with mainMod + M
	  {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + M\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'\")") ];}
	  
	  # Open textual file explorer with mainMod + E
	  {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + E\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(filesTUI)") ];}
	  
	  # Open graphical file explorer with mainMod + Shift + E
	  {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + SHIFT + E\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(filesGUI)") ];}
	  
	  # Reposition window with mainMod + Drag-left-click
	  {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + mouse:272\"") (lib.generators.mkLuaInline "hl.dsp.window.drag()") ];}
	  
	  # Resize window with mainMod + Drage-right-click
	  {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + mouse:273\"") (lib.generators.mkLuaInline "hl.dsp.window.resize()") ];}
        ]

	# Switch to workspace via mainMod + 0-9
	# Move window to workspace via mainMod + Shift + 0-9
	++ builtins.concatLists (builtins.genList(i:
          let workspace = i + 1;
	  in [
	    {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + \" .. (${toString workspace} % 10)") (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = ${toString workspace} })") ];}
	    {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + SHIFT + \" .. (${toString workspace} % 10)") (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = ${toString workspace} })") ];}
	  ]
	) 10);
      };
    };
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
    kdePackages.dolphin
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
