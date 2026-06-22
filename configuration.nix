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
      ./boot.nix
      ./rice.nix
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
          command = "/run/current-system/sw/bin/shutdown";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/reboot";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl suspend";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl reboot";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl poweroff";
          options = [ "NOPASSWD" ];
        }
      ];
    }];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mathcrafted = {
    isNormalUser = true;
    description = "mathcrafted";
    extraGroups = [ "networkmanager" "wheel" "seat" "audio" "realtime" "wireshark" ];
    packages = with pkgs; [
      claude-code
    ];
  };

  home-manager.users.mathcrafted = { pkgs, ... }: {
    home.stateVersion = "26.05";
    
    programs.bash.enable = true;
    programs.kitty.enable = true;
    programs.firefox.enable = true;
    services.kdeconnect.enable = true;
  };


  ############
  # Packages #
  ############

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    
    # Kernel-level
    sof-firmware

    # CLI
    busybox
    playerctl
    brightnessctl
    git
    fastfetch
    sl
    bonsai
    cmatrix
    cowsay
    lolcat

    # Desktop Shell Layer
    dunst
    nerd-fonts.noto
    grim
    slurp
    wl-clipboard
    hyprpolkitagent

    # GUI utilities
    superfile
    kdePackages.dolphin
    kitty
    neovide
    firefox
    gparted
    mission-center
    vlc
    piper
    libreoffice

    # Art
    gimp
    blender
    davinci-resolve
    inkscape
    libresprite
    lmms

    # Development
    qemu-utils
    socat

    # Communication
    webcord

    # Productivity
    strawberry

  ];

  specialisation.gaming = {
    configuration = {
      environment.systemPackages = with pkgs; [
        
        azahar
        dolphin-emu
        lunar-client
        vintagestory
        wine64

      ];

      programs.steam = {
        enable = true;
        protontricks.enable = true;
      };
    };
  };

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "firefox.desktop";
      "text/plain" = "neovide.desktop";
      "text/html" = [
        "firefox.desktop"
        "neovide.desktop"
      ];
      "text/*" = "neovide.desktop";
      "image/x-xcf" = "gimp.desktop";
      "image/png" = [
        "firefox.desktop"
        "gimp.desktop"
      ];
      "image/jpeg" = [
        "firefox.desktop"
        "gimp.desktop"
      ];
      "image/svg+xml" = [
        "firefox.desktop"
        "gimp.desktop"
      ];
      "audio/*" = "vlc.desktop";
      "video/*" = "vlc.desktop";
      "application/x-blender" = "blender.desktop";
    };
  };

  ############
  # Programs #
  ############

  programs.hyprland = {
    enable = true;
    withUWSM = false; # UWSM not working, don't know why
  };

  programs.uwsm.enable = false;

  programs.hyprlock.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    configure = {
      customRC = ''
	set number
        set relativenumber
        tnoremap <Esc> <C-\><C-N>
      '';
      packages.myPlugins = with pkgs.vimPlugins; {
        start = [ vim-nix vim-suda ];
        opt = [];
      };
    };
  };

  programs.ssh.startAgent = true;

  virtualisation.podman = {
    enable = true;
  };

  programs.obs-studio = {
    enable = true;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
    dumpcap.enable = true; # Capture network traffic
    usbmon.enable = false; # Capture usb traffic
  };

  programs.kdeconnect.enable = true;


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

  services.ratbagd.enable = true;

  services.displayManager.lemurs = {
    enable = true;
    #settings = "";
  };

  hardware.firmware = [
    pkgs.sof-firmware
  ];
  hardware.alsa.enablePersistence = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig.pipewire."60-custom-sink"."context.modules" = [
      {
        name = "libpipewire-module-loopback";
	args."capture.props" = {
	  "media.class" = "Audio/Sink";
	  "node.name" = "custom.soundcraft.out.7-8";
	  "node.description" = "Soundcraft 7/8 Out";
	  "audio.position" = [ "FL" "FR" ];
	};
	args."playback.props" = {
	  "node.name" = "custom.soundcraft.hw-out.7-8";
	  "node.description" = "";
	  "audio.position" = [ "AUX6" "AUX7" ];
	  "node.target" = "alsa_output.usb-Soundcraft_Soundcraft_Signature_12_MTK-00.pro_output-0";
	};
      }
      {
        name = "libpipewire-module-loopback";
	args."capture.props" = {
	  "media.class" = "Audio/Sink";
	  "node.name" = "custom.soundcraft.out.9-10";
	  "node.description" = "Soundcraft 9/10 Out";
	  "audio.position" = [ "FL" "FR" ];
	};
	args."playback.props" = {
	  "node.name" = "custom.soundcraft.hw-out.9-10";
	  "node.description" = ".";
	  "audio.position" = [ "AUX8" "AUX9" ];
	  "node.target" = "alsa_output.usb-Soundcraft_Soundcraft_Signature_12_MTK-00.pro_output-0";
	};
      }
      {
        name = "libpipewire-module-loopback";
	args."capture.props" = {
	  "media.class" = "Audio/Sink";
	  "node.name" = "custom.soundcraft.out.11-12";
	  "node.description" = "Soundcraft 11/12 Out";
	  "audio.position" = [ "FL" "FR" ];
	};
	args."playback.props" = {
	  "node.name" = "custom.soundcraft.hw-out.11-12";
	  "node.description" = ".";
	  "audio.position" = [ "AUX10" "AUX11" ];
	  "node.target" = "alsa_output.usb-Soundcraft_Soundcraft_Signature_12_MTK-00.pro_output-0";
	};
      }
      {
        name = "libpipewire-module-loopback";
	args."capture.props" = {
	  "audio.position" = [ "AUX8" ];
	  "stream.dont-remix" = true;
	  "node.passive" = true;
	  "node.target" = "alsa_input.usb-Soundcraft_Soundcraft_Signature_12_MTK-00.pro_input-0";
	};
	args."playback.props" = {
	  "node.name" = "custom.soundcraft.in.9";
	  "audio.position" = [ "MONO" ];
	  "media.class" = "Audio/Source";
	};
      }
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;


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

  # Open ports in the firewall.
  networking.firewall = {
    enable = false;
    logRefusedPackets = true;  # should show up in dmesg
    allowedTCPPortRanges = [ 
      { from=1714; to=1764; }
    ];
    allowedUDPPortRanges = [ 
      { from=1714; to=1764; }
    ];
  };


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
