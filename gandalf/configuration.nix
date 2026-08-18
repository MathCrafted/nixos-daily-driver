# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, home-manager, ... }:

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-26.05/";


  ###########
  # Imports #
  ###########

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./boot.nix
      ./rice.nix

      # "${builtins.fetchTarball {
      #   url = "https://github.com/ryantm/agenix/archive/564595d0ad4be7277e07fa63b5a991b3c645655d.tar.gz";
      #   # update hash from nix build output
      #   sha256 = "";
      # }}/modules/age-home.nix"
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
  #time.timeZone = "America/New_York";
  time.timeZone = "America/Chicago";


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

        {
          command = "/run/current-system/sw/bin/nmcli";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/rfkill";
          options = [ "NOPASSWD" ];
        }
      ];
    }];
  };

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };

  services.udev = {
    enable = true;
    extraRules = ''
      #SUBSYSTEM=="usb", ATTRS{idVendor}=="0x8087", ATTRS{idProduct}=="0x0029", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0x0403", ATTRS{idProduct}=="0x6001", TAG+="uaccess"
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mathcrafted = {
    isNormalUser = true;
    description = "mathcrafted";
    extraGroups = [ "networkmanager" "wheel" "seat" "audio" "realtime" "wireshark" "plugdev" "cdrom" "video" "rfkill" "dialout" ];
    packages = with pkgs; [
      claude-code
    ];
  };

  home-manager.users.mathcrafted = { pkgs, ... }: {
    home.stateVersion = "26.05";
    
    programs.bash = {
      enable = true;
      profileExtra = ''
        echo "" > /home/mathcrafted/log.txt; for file in $(ls -1 ~/.ssh | grep -E "^id_" | grep -Ev ".pub$"); do ssh-add ~/.ssh/$file; echo $file >> /home/mathcrafted/log.txt; done
      '';
    };
    programs.kitty.enable = true;
    programs.firefox = {
      enable = true;
      languagePacks = [
        "en-US"
      ];
    };
    programs.obsidian = {
      enable = true;
      package = pkgs.obsidian;
      defaultSettings = {
        hotkeys."command-palette:open" = {
          key = " ";
          modifiers = "Mod";
        };
      };
    };
    services.kdeconnect.enable = true;
    home.file = {
      ".config/aacs/KEYDB.cfg" = {
        enable = true;
        force = true;
        source = ./files/KEYDB.cfg;
      };
      # "Obsidian/" = {
      #   enable = true;
      #   force = false;
      #   source = ./files/emptyFolder;
      # };
    };
    # services.git-sync = {
    #   enable = true;
    #   repositories = {
    #     notes = {
    #       path = /home/mathcrafted/Obsidian;
    #       uri = "git@github.com:MathCrafted/Obsidian.git";
    #     };
    #   };
    # };
  };


  ############
  # Packages #
  ############

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  home-manager.useGlobalPkgs = true;

  # Overlays
  nixpkgs.overlays = [
    # (final: prev: {
    #   vlc = prev.vlc.override {
    #     libbluray-full = prev.libbluray.override {
    #       withAACS = true;
    #       withBDplus = true;
    #     };
    #   };
    # })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    
    # Kernel-level
    sof-firmware
    libcamera

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
    cifs-utils
    wineWow64Packages.stable
    winetricks
    steam-run
    cifs-utils

    # Desktop Shell Layer
    dunst
    freetype
    fontconfig
    nerd-fonts.noto
    grim
    slurp
    wl-clipboard

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
    makemkv
    handbrake
    mkvtoolnix
    mkvtoolnix-cli
    localsend

    # Art
    gimp
    davinci-resolve

    # Development
    qemu-utils
    socat
    arduino-ide
    podman-compose
    putty
    zenmap

    # Communication
    webcord

    # Productivity
    feishin

  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.noto
      nerd-fonts.commit-mono
      noto-fonts
    ];
  };

  specialisation.productivity = {
    configuration = {
      environment.systemPackages = with pkgs; [
        #
      ];
    };
  };

  specialisation.animation = {
    configuration = {
      environment.systemPackages = with pkgs; [
        inkscape
        blender
        libresprite
      ];
    };
  };

  specialisation.music = {
    configuration = {
      environment.systemPackages = with pkgs; [
        lmms
        openutau
      ];
    };
  };

  specialisation.gaming = {
    configuration = {
      environment.systemPackages = with pkgs; [
        
        azahar
        dolphin-emu
        lunar-client
        vintagestory
        openrct2

      ];

      programs.steam = {
        enable = true;
        protontricks.enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };

      programs.gamemode.enable = true;

      services.udev = {
        enable = true;
        extraRules = ''
          SUBSYSTEM=="usb", ATTRS{idVendor}=="0x8087", ATTRS{idProduct}=="0x0029", TAG+="uaccess"
        '';
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
        cnoremap sudo SudaWrite
        term
      '';
      customLuaRC = ''
        vim.api.nvim_create_autocmd("TermResponse", {
          callback = function()
            print("Event fired")
            local _, cwd = pcall(vim.fn.expand, "<amatch>")
            print(cwd)
            if cwd and cwd:sub(1, 7) == "file://" then
              local path = cwd:sub(8)
              vim.cmd("cd " .. vim.fn.fnameescape(path))
            end
          end,
        })
      '';
      packages.myPlugins = with pkgs.vimPlugins; {
        start = [ vim-nix vim-suda ];
        opt = [];
      };
    };
  };

  programs.ssh.startAgent = true;
  systemd.user.services.add-sshkeys = {
    description = "Add ssh keys in ~/.ssh after ssh-agent has started";
    wantedBy = [ "default.target" ];
    wants = [ "ssh-agent.service" ];
    after = [ "ssh-agent.service" ];
    #preStart = "${pkgs.coreutils-full}/bin/sleep 3";
    environment = {
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
    };
    script = "for file in $(ls -1 ~/.ssh | ${pkgs.gnugrep}/bin/grep -E \"^id_\" | ${pkgs.gnugrep}/bin/grep -Ev \".pub$\"); do ${pkgs.openssh}/bin/ssh-add ~/.ssh/$file; done";
    serviceConfig = {
      User = "%u";
      Type = "exec";
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
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

  services.upower = {
    enable = true;

    usePercentageForPolicy = true;
    percentageLow = 10;
    percentageCritical = 3;
    percentageAction = 1;
  };

  systemd.services.sleep-lock = {
    enable = true;
    description = "Lock the screen when suspending or hibernating lol";
    wantedBy = [ "suspend.target" ];
    before = [ "suspend.target" ];
    environment = {
      DISPLAY = ":0";
      XDG_CONFIG_HOME = "/home/mathcrafted/.config";
    };
    serviceConfig = {
      User = "%u";
      Type = "exec";
      ExecStart = "/run/current-system/sw/bin/hyprlock -v";
    };
  };

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

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

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
    trustedInterfaces = [
      config.services.tailscale.interfaceName
    ];
    allowedTCPPorts = [
      #
    ];
    allowedTCPPortRanges = [ 
      { from=1714; to=1764; }
    ];
    allowedUDPPorts = [
      config.services.tailscale.port
      69
    ];
    allowedUDPPortRanges = [ 
      { from=1714; to=1764; }
    ];
  };

  services.tailscale.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services.gvfs = {
    enable = true;
    package = lib.mkForce pkgs.gnome.gvfs;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
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
