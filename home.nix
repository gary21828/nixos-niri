{ pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
  };

  flake = "$HOME/nixos-dotfiles";

in
{
  home = {
    stateVersion = "26.05";

    packages = (with pkgs; [
      # Additional desktop / quality-of-life
      # Terminals / tools (some already in system for session)
      htop
      ripgrep
      fd
      jq
      unzip
      p7zip
      # Icons & fonts for Waybar
      adwaita-icon-theme
      papirus-icon-theme
    ]) ++ [ unstable.opencode ];
  };

  # Browsers
  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.librewolf.enable = true;

  # Bash
  programs.bash = {
    enable = true;

    shellAliases = {
      # Update flake inputs and rebuild
      update = "nix flake update --flake ${flake} && sudo nixos-rebuild switch --flake ${flake}#nixos";

      # Rebuild without updating flake inputs
      rebuild = "sudo nixos-rebuild switch --flake ${flake}#nixos";

      # Garbage collection and clean up
      cleanup = "sudo nix-collect-garbage --delete-older-than 15d";

      # Store optimization
      optimise = "nix store optimise";

      # Search packages
      search = "nix search nixpkgs";

      # List system generations
      generations = "nixos-rebuild list-generations";
    };
  };

  # Waybar (based on niri_configuration.nix defaults, themed to match Niri)
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 6;
        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "pulseaudio" "network" "cpu" "memory" "temperature" "battery" "power-profiles-daemon" ];

        "niri/workspaces" = {
          format = "{index}";
        };

        "niri/window" = {
          format = "{title}";
          max-length = 60;
        };

        clock = {
          format = "{:%a %d %b  %H:%M}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        pulseaudio = {
          format = "vol {volume}%";
          format-muted = "muted";
          on-click = "pavucontrol";
          scroll-step = 5;
        };

        network = {
          format-wifi = "wifi {essid} {signalStrength}%";
          format-ethernet = "ethernet";
          format-disconnected = "offline";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        };

        cpu = {
          format = "cpu {usage}%";
          interval = 3;
        };

        memory = {
          format = "mem {percentage}%";
          interval = 5;
        };

        temperature = {
          format = "temp {temperatureC}°C";
          format-critical = "temp {temperatureC}°C";
          critical-threshold = 80;
          interval = 5;
        };

        battery = {
          format = "bat {capacity}%";
          format-charging = "bat {capacity}% +";
          states = {
            warning = 30;
            critical = 15;
          };
        };

        power-profiles-daemon = {
          format = "{profile}";
          tooltip = false;
        };

        tray = {
          spacing = 8;
        };
      };
    };

    style = ''
      * {
        font-family: "Noto Sans", "Font Awesome 6 Free", sans-serif;
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.88);
        color: #cdd6f4;
      }

      #workspaces button {
        padding: 0 8px;
        margin: 3px 2px;
        border-radius: 6px;
        background: transparent;
        color: #cdd6f4;
      }

      #workspaces button.active {
        background: #89b4fa;
        color: #1e1e2e;
      }

      #window {
        margin-left: 12px;
        color: #a6adc8;
      }

      #clock,
      #pulseaudio,
      #network,
      #cpu,
      #memory,
      #temperature,
      #battery,
      #power-profiles-daemon,
      #tray {
        padding: 0 8px;
        margin: 3px 0;
      }

      #temperature.critical {
        color: #f38ba8;
      }

      #battery.warning {
        color: #f9e2af;
      }

      #battery.critical {
        color: #f38ba8;
      }
    '';
  };

  # GNOME / GTK interface font (used by Nautilus and other GNOME apps)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      font-name = "Noto Sans 13";
      document-font-name = "Noto Sans 13";
      monospace-font-name = "Noto Sans Mono 13";
    };
  };

  # Night light (wlsunset) — manual schedule 17:30–07:30
  services.wlsunset = {
    enable = true;
    temperature = {
      day = 5200;
      night = 3200;
    };
    sunset = "17:30";
    sunrise = "07:30";
  };

  # Alacritty — Catppuccin Mocha (matches Niri / Waybar / swaylock)
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.7;
        padding = {
          x = 8;
          y = 8;
        };
        decorations = "Full";
      };

      font = {
        normal = {
          family = "Maple Mono NF CN";
          style = "Regular";
        };
        bold = {
          family = "Maple Mono NF CN";
          style = "Bold";
        };
        italic = {
          family = "Maple Mono NF CN";
          style = "Italic";
        };
        size = 12.0;
      };

      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
        };
        cursor = {
          text = "#1e1e2e";
          cursor = "#f5e0dc";
        };
        selection = {
          text = "#1e1e2e";
          background = "#f5e0dc";
        };
        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
        bright = {
          black = "#585b70";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };
      };
    };
  };

  # Themed lock screen (Catppuccin Mocha, matches Waybar / Niri)
  programs.swaylock = {
    enable = true;
    settings = {
      color = "1e1e2e";
      font-size = 24;
      indicator-idle-visible = true;
      indicator-radius = 100;
      indicator-thickness = 7;
      line-color = "00000000";
      ring-color = "89b4fa";
      inside-color = "1e1e2e";
      key-hl-color = "a6e3a1";
      separator-color = "00000000";
      text-color = "cdd6f4";
      text-caps-lock-color = "";
      line-ver-color = "89b4fa";
      ring-ver-color = "89b4fa";
      inside-ver-color = "1e1e2e";
      text-ver-color = "cdd6f4";
      ring-wrong-color = "f38ba8";
      text-wrong-color = "f38ba8";
      inside-wrong-color = "1e1e2e";
      inside-clear-color = "1e1e2e";
      ring-clear-color = "a6e3a1";
      text-clear-color = "a6e3a1";
      show-failed-attempts = true;
      clock = true;
      indicator = true;
      daemonize = true;
    };
  };

  # Niri config
  xdg.configFile."niri/config.kdl".text = ''
    // Modern polished Niri config
    // https://niri-wm.github.io/niri/Configuration:-Introduction

    input {
        keyboard {
            xkb {
                layout "us"
            }
            numlock
        }

        touchpad {
            tap
            natural-scroll
            dwt
        }

        mouse {
            natural-scroll
        }
    }

    layout {
        gaps 12

        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        focus-ring {
            width 3
            active-color "#89b4fa"
            inactive-color "#45475a"
        }

        border {
            off
        }

        shadow {
            on
            softness 24
            spread 2
            offset x=0 y=4
            color "#1e1e2e80"
            draw-behind-window true
        }

        struts {
            top 8
        }
    }

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    animations {
        // smooth defaults
    }

    // Rounded corners for all windows
    window-rule {
        geometry-corner-radius 10
        clip-to-geometry true
    }

    // Alacritty: distinct border
    window-rule {
        match app-id="Alacritty"
        border {
            on
            width 3
            active-color "#f9e2af"
            inactive-color "#585b70"
        }
        focus-ring {
            off
        }
    }

    // Firefox PiP floating
    window-rule {
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        open-floating true
    }

    // Startup
    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "swaybg" "-c" "#1e1e2e"

    hotkey-overlay {
        skip-at-startup
    }

    binds {
        // Apps
        Mod+T { spawn "alacritty"; }
        Mod+D { spawn "fuzzel"; }
        Mod+B { spawn "firefox"; }
        Super+Alt+L { spawn "swaylock" "-f"; }

        // Overview
        Mod+O { toggle-overview; }

        // Close / quit
        Mod+Q { close-window; }
        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }

        // Focus
        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up    { focus-window-up; }
        Mod+Down  { focus-window-down; }
        Mod+H     { focus-column-left; }
        Mod+L     { focus-column-right; }
        Mod+K     { focus-window-up; }
        Mod+J     { focus-window-down; }
        Mod+Home  { focus-column-first; }
        Mod+End   { focus-column-last; }

        // Move
        Mod+Ctrl+Left  { move-column-left; }
        Mod+Ctrl+Right { move-column-right; }
        Mod+Ctrl+Up    { move-window-up; }
        Mod+Ctrl+Down  { move-window-down; }
        Mod+Ctrl+H     { move-column-left; }
        Mod+Ctrl+L     { move-column-right; }
        Mod+Ctrl+K     { move-window-up; }
        Mod+Ctrl+J     { move-window-down; }
        Mod+Shift+Left  { move-column-to-monitor-left; }
        Mod+Shift+Right { move-column-to-monitor-right; }
        Mod+Shift+Up    { move-column-to-monitor-up; }
        Mod+Shift+Down  { move-column-to-monitor-down; }

        // Workspaces
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }
        Mod+Tab { focus-workspace-previous; }

        // Layout
        Mod+R       { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R  { reset-window-height; }
        Mod+F       { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+Ctrl+F  { expand-column-to-available-width; }
        Mod+C       { center-column; }
        Mod+Minus   { set-column-width "-10%"; }
        Mod+Equal   { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }
        Mod+V       { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }
        Mod+W       { toggle-column-tabbed-display; }

        // Consume / expel
        Mod+BracketLeft  { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }
        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        // Screenshots
        Print      { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print  { screenshot-window; }

        // Media / brightness (via playerctl / brightnessctl)
        XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute        { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioPlay        { spawn "playerctl" "play-pause"; }
        XF86AudioNext        { spawn "playerctl" "next"; }
        XF86AudioPrev        { spawn "playerctl" "previous"; }
        XF86MonBrightnessUp   { spawn "brightnessctl" "set" "+5%"; }
        XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

        // Power
        Mod+Shift+P { spawn "niri" "msg" "action" "power-off-monitors"; }
    }
  '';
}
