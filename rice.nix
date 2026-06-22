{ config, pkgs, lib, ... }:

let

  user = "mathcrafted";

  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz;

in

{

  system.activationScripts.clearQuickshellConfig = {
    text = ''
      rm -r /home/${user}/.config/quickshell || true
      rm -r /home/${user}/.config/superfile || true
      '';
  };

  home-manager.users.${user} = { pkgs, ... }: {
    
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
    
    programs.ashell = {
      enable = true;
      settings = {
        layer = "Top";
        enable_esc_key = true;
        modules = {
          left = [
            "Tray"
            "Clock"
          ];
          center = [
            "Workspaces"
          ];
          right = [
            "SystemInfo"
            "Settings"
          ];
        };
        #workspaces.visibilityMode = "MonitorSpecific";
        settings.shutdown_cmd = "sudo shutdown now";
        settings.reboot_cmd = "sudo reboot";
        settings.indicators = [ "Battery" "Audio" "Network" ];
        settings.battery_format = "IconAndPercentage";
        settings.peripheral_battery_format = "IconAndPercentage";
      };
    };

    programs.tofi.enable = true;

    programs.superfile = {
      enable = true;
      package = pkgs.superfile;
      settings = {
        cd_on_quit = true;
        theme = "catpuccin";
        editor = "";
        dir_editor = "";
        auto_check_update = false;
        default_open_file_preview = true;
        show_image_preview = true;
        default_directory = ".";
        file_size_use_si = false;
        default_sort_type = 0;
        sort_order_reversed = false;
        case_sensitive_sort = false;
        ignore_missing_fields = true;
      };
    };

    programs.bash = {
      enable = true;
      bashrcExtra = ''
        spf() {
          os=$(uname -s)
        
          # Linux
          if [[ "$os" == "Linux" ]]; then
            export SPF_LAST_DIR="$HOME/.local/state/superfile/lastdir"
          fi
        
          # macOS
          if [[ "$os" == "Darwin" ]]; then
            export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
          fi
        
          command spf "$@"
        
          [ ! -f "$SPF_LAST_DIR" ] || {
            . "$SPF_LAST_DIR"
            rm -f -- "$SPF_LAST_DIR" > /dev/null
          }
        }
      '';
    };

    programs.quickshell = {
      enable = true;
      systemd.enable = true;
      systemd.target = "hyprland-session.target";
      configs = { "." = "/etc/nixos/quickshell/"; };
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
	    mode = "1920x1080";
	    position = "-1920x0";
	    scale = 1;
	  }
	];


	##########
	# CONFIG #
	##########
        config.input = {
          numlock_by_default = true;
	  touchpad.natural_scroll = false;
	  tablet.output = "current";
	};

	############
        # PROGRAMS #
        ############
        quickshell._var = "quickshell";
	search._var = "rm $HOME/.cache/tofi-drun && tofi-drun --drun-launch=true"; # Search command
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
	  (lib.generators.mkLuaInline "function()\nhl.exec_cmd(toolbar)\nhl.exec_cmd(\"kdeconnect-indicator\")\nend")
        ];

        ################
        # WINDOW RULES #
        ################
        window_rule = [
          {
            name = "KDE Connect Pointer";
            match = {
              initial_title = "KDE Connect Daemon";
            };
            float = true;
            fullscreen_state = "0";
            size = lib.generators.mkLuaInline "{\"monitor_w\", \"(monitor_h)\"}";
            center = true;
            no_blur = true;
            no_focus = true;
            pin = true;
          }
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

  };

}
