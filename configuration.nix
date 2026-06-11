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
    extraGroups = [ "networkmanager" "wheel" "seat" "audio" "realtime" "wireshark" ];
    packages = with pkgs; [];
  };

  home-manager.users.mathcrafted = { pkgs, ... }: {
    home.stateVersion = "26.05";
    
    programs.bash.enable = true;
    programs.kitty.enable = true;
    programs.firefox.enable = true;
    programs.hyprlock = {
      package = null;
      settings = {
        general = {
	  hide_cursor = true;
	  ignore_empty_input = true;
	};
	background = [
	  {
	    path = "screenshot";
	    blur_passes = 3;
	    blur_size = 8;
	  }
	];
      };
    };
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      configType = "lua";
      settings = {
	
	############
	# MONITORS #
	############
	
        monitor = [
	  {
	    output = "eDP-1";
	    mode = "preferred";
	    position = "0x0";
	    scale = 1;
	  }
	  {
	    output = "DP-1";
	    mode = "preferred";
	    position = "1920x-1080";
	    scale = 1;
	    transform = 1;
	  }
	  {
	    output = "HDMI-A-1";
	    mode = "preferred";
	    position = "-1920x0";
	    scale = 1;
	  }
	];


	##########
	# CONFIG #
	##########
	config.input = {
	  touchpad.natural_scroll = false;
	  tablet.output = "current";
	};

	############
        # PROGRAMS #
        ############
	search._var = "tofi-drun --drun-launch=true"; # Search command
	terminal._var = "kitty"; # Terminal command
	filesGUI._var = "dolphin"; # Graphical file explorer command
	filesTUI._var = "kitty -o confirm_os_window_close=0 superfile"; # Text file explorer command
	toolbar._var = "ashell"; # Toolbar command
        lock._var = "hyprlock"; # Lock command
        screenshot._var = "grim -g \"$(slurp -d)\" - | wl-copy";
        
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

	  # Lock screen with mainMod + L
	  {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + ESCAPE\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(lock)") ];}
	  
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
	) 10)

	# Switch window by direction
	++ [
          {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + K \"") (lib.generators.mkLuaInline "hl.dsp.focus({ direction=\"up\"})") ];}
          {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + SHIFT + K \"") (lib.generators.mkLuaInline "hl.dsp.window.swap({ direction=\"up\"})") ];}
          
          {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + J \"") (lib.generators.mkLuaInline "hl.dsp.focus({ direction=\"down\"})") ];}
          {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + SHIFT + J \"") (lib.generators.mkLuaInline "hl.dsp.window.swap({ direction=\"down\"})") ];}
          
          {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + H \"") (lib.generators.mkLuaInline "hl.dsp.focus({ direction=\"left\"})") ];}
          {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + SHIFT + H \"") (lib.generators.mkLuaInline "hl.dsp.window.swap({ direction=\"left\"})") ];}
          
          {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + L \"") (lib.generators.mkLuaInline "hl.dsp.focus({ direction=\"right\"})") ];}
          {_args=[ (lib.generators.mkLuaInline "mainMod .. \" + SHIFT + L \"") (lib.generators.mkLuaInline "hl.dsp.window.swap({ direction=\"right\"})") ];}
	]

	# Multimedia keys
	++ [

	  # Volume controls
	  {_args=[ (lib.generators.mkLuaInline "\"XF86AudioRaiseVolume\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+\")") (lib.generators.mkLuaInline "{locked = true, repeating = true}") ];}
	  {_args=[ (lib.generators.mkLuaInline "\"XF86AudioLowerVolume\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")") (lib.generators.mkLuaInline "{locked = true, repeating = true}") ];}
	  {_args=[ (lib.generators.mkLuaInline "\"XF86AudioMute\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")") (lib.generators.mkLuaInline "{locked = true}") ];}
	  
	  # Brightness controls
	  {_args=[ (lib.generators.mkLuaInline "\"XF86MonBrightnessUp\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 5%+\")") (lib.generators.mkLuaInline "{locked = true, repeating = true}") ];}
	  {_args=[ (lib.generators.mkLuaInline "\"XF86MonBrightnessDown\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 5%+\")") (lib.generators.mkLuaInline "{locked = true, repeating = true}") ];}
	  
	  {_args=[ (lib.generators.mkLuaInline "\"XF86AudioNext\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl next\")") (lib.generators.mkLuaInline "{locked = true}") ];}
	  {_args=[ (lib.generators.mkLuaInline "\"XF86AudioPause\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")") (lib.generators.mkLuaInline "{locked = true}") ];}
	  {_args=[ (lib.generators.mkLuaInline "\"XF86AudioPlay\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")") (lib.generators.mkLuaInline "{locked = true}") ];}
	  {_args=[ (lib.generators.mkLuaInline "\"XF86AudioPrev\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl previous\")") (lib.generators.mkLuaInline "{locked = true}") ];}
        ]

        # Screenshot
        ++ [

          # PrintScreen
          {_args=[ (lib.generators.mkLuaInline "\"Print\"") (lib.generators.mkLuaInline "hl.dsp.exec_cmd(screenshot)") ];}
        
        ];
      };
    };
    programs.ashell = {
      enable = true;
      settings = {
        modules = {
          left = [];
          center = [
            "Workspaces"
          ];
          right = [
            "SystemInfo"
            [
              "Clock"
              "Settings"
            ]
          ];
        };
        #workspaces.visibilityMode = "MonitorSpecific";
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
    
    # Kernel-level
    sof-firmware

    # CLI
    busybox
    #lsof # contained in busybox
    playerctl
    brightnessctl
    git
    #wget # contained in busybox
    fastfetch
    sl
    bonsai
    cmatrix
    cowsay
    lolcat

    # Desktop Shell Layer
    tofi
    dunst
    quickshell
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

    # Art
    gimp
    blender
    davinci-resolve
    inkscape
    libresprite
    lmms

    # Development
    qemu-utils

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

      ];

      programs.steam = {
        enable = true;
        protontricks.enable = true;
      };
    };
  };

  ##############
  # Pkg Config #
  ##############

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
