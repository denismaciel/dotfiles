{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.niri;
in
{
  options.niri = {
    enable = mkEnableOption "niri window manager configuration";
    dennichPkg = mkOption {
      type = types.package;
      description = "The dennich package to use for waybar modules";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Custom run-or-raise script for niri with centering behavior
      (pkgs.writeShellScriptBin "run-or-raise" ''
        #!/usr/bin/env bash
        # Usage: run-or-raise <app-id> <command...>
        # For scratchpad-like windows - centers and focuses, or focuses previous window if already focused
        set -euo pipefail
        APP_ID="$1"; shift || true
        CMD="''${*:-$APP_ID}"

        # Get focused window info
        FOCUSED_WINDOW="$(${pkgs.niri}/bin/niri msg -j focused-window 2>/dev/null || echo "{}")"
        FOCUSED_APP_ID="$(echo "$FOCUSED_WINDOW" | ${pkgs.jq}/bin/jq -r '.app_id // empty' 2>/dev/null || echo "")"

        # Find first matching window
        ID="$(${pkgs.niri}/bin/niri msg -j windows | ${pkgs.jq}/bin/jq -r --arg id "$APP_ID" '.[] | select(.app_id==$id) | .id' | head -n1)"

        if [ -n "''${ID:-}" ]; then
          # Window exists - check if it's currently focused
          if [ "$FOCUSED_APP_ID" = "$APP_ID" ]; then
            # Already focused, focus previous window instead of closing
            ${pkgs.niri}/bin/niri msg action focus-window-previous
          else
            # Not focused, focus it and center
            ${pkgs.niri}/bin/niri msg action focus-window --id "$ID" && ${pkgs.niri}/bin/niri msg action center-column
          fi
        else
          # Window doesn't exist, spawn it
          exec sh -lc "$CMD"
        fi
      '')


    ];

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          spacing = 4;

          modules-left = [ "niri/workspaces" ];
          modules-center = [ "niri/window" ];
          modules-right = [
            "custom/pomodoro"
            "memory"
            "cpu"
            "disk"
            "network"
            "battery"
            "clock"
            "tray"
          ];

          "niri/workspaces" = {
            format = "{icon}";
            format-icons = {
              active = "";
              default = "";
            };
          };

          "niri/window" = {
            format = "{}";
            max-length = 50;
          };

          clock = {
            format = "{:%Y-%m-%d %H:%M}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-disconnected = "Disconnected ⚠";
          };

          memory = {
            interval = 2;
            format = "󰍛 {percentage}%";
          };

          cpu = {
            interval = 2;
            format = "󰻠 {usage}%";
          };

          disk = {
            interval = 25;
            format = "󰋊 {percentage_used}%";
            path = "/";
          };

          battery = {
            format = "󰁹 {capacity}% {icon}";
            format-charging = "󰂄 {capacity}% {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
            states = {
              warning = 30;
              critical = 15;
            };
          };

          tray = {
            spacing = 10;
          };

          "custom/pomodoro" = {
            format = "{}";
            interval = 1;
            exec = "${cfg.dennichPkg}/bin/dennich-todo today-status --format waybar-json";
            return-type = "json";
          };
        };
      };

      style = ''
        * {
          font-family: "Comic Shanns Mono Nerd Font";
          font-size: 13px;
          border: none;
          border-radius: 0;
          min-height: 0;
        }

        window#waybar {
          background-color: rgba(30, 30, 46, 0.9);
          color: #cdd6f4;
          transition-property: background-color;
          transition-duration: .5s;
        }

        #workspaces {
          background-color: transparent;
        }

        #workspaces button {
          padding: 0 8px;
          background-color: transparent;
          color: #cdd6f4;
        }

        #workspaces button:hover {
          background-color: rgba(69, 71, 90, 0.8);
        }

        #workspaces button.active {
          background-color: #89b4fa;
          color: #1e1e2e;
        }

        #window {
          background-color: rgba(17, 17, 27, 0.8);
          padding: 0 15px;
          margin: 0 5px;
          border-radius: 5px;
        }

        #clock,
        #battery,
        #network,
        #tray {
          padding: 0 10px;
          margin: 0 2px;
          background-color: rgba(17, 17, 27, 0.8);
          border-radius: 5px;
        }

        #battery.critical:not(.charging) {
          background-color: #f38ba8;
          color: #1e1e2e;
          animation: blink 0.5s linear infinite alternate;
        }

        @keyframes blink {
          to {
            background-color: #f7768e;
            color: #24283b;
          }
        }

        /* Pomodoro status styles */
        #custom-pomodoro.pomodoro-running {
          background-color: rgba(17, 17, 27, 0.8);
          color: #cdd6f4;
        }

        #custom-pomodoro.pomodoro-idle {
          background-color: rgba(17, 17, 27, 0.8);
          color: #cdd6f4;
        }

        #custom-pomodoro.pomodoro-idle-blink {
          background-color: #f38ba8;
          color: #1e1e2e;
        }
      '';
    };

    # Niri configuration with complete custom setup
    programs.niri.settings = {
      input = {
        keyboard = {
          repeat-delay = 250; # 250ms delay before repeat starts (faster than default 600ms)
          repeat-rate = 50; # 50 repetitions per second (faster than default 25)
        };
      };

      layout = {
        gaps = 3;

        # Window border configuration
        border = {
          enable = true;
          width = 2; # Thinner border (default is usually 4)
          active.color = "#888888"; # Muted gray for active window
          inactive.color = "#333333"; # Darker gray for inactive windows
        };
      };

      # Animation settings - make them faster
      animations = {
        slowdown = 0.1; # Speed multiplier (0.1 = 10x faster)
      };

      # Window rules - keeping only corner radius, removed floating except for pomodoro launcher
      window-rules = [
        # Generic rounded corners for all windows
        {
          geometry-corner-radius = {
            top-left = 10.0;
            top-right = 10.0;
            bottom-right = 10.0;
            bottom-left = 10.0;
          };
        }

        # Floating dialog for pomodoro launcher (Mod+R) - ONLY floating window
        {
          matches = [ { app-id = "^com\\.denis\\.float$"; } ];
          open-floating = true;
          default-column-width = {
            fixed = 800;
          };
          default-window-height = {
            fixed = 400;
          };
        }

        # Set default column widths for previously floating apps (now tiled)
        {
          matches = [ { app-id = "^com\\.denis\\.scratchpad$"; } ];
          default-column-width = {
            fixed = 900;
          };
        }

        {
          matches = [ { app-id = "^com\\.denis\\.notebook$"; } ];
          default-column-width = {
            fixed = 1200;
          };
        }

        {
          matches = [ { app-id = "^(?i)(keepassxc|1password|bitwarden)$"; } ];
          default-column-width = {
            fixed = 1000;
          };
        }

        {
          matches = [ { app-id = "^(?i)(anki|chat|todos)$"; } ];
          default-column-width = {
            fixed = 1000;
          };
        }
      ];

      binds = with config.lib.niri.actions; {
        # System
        "Mod+Shift+Slash".action = show-hotkey-overlay;
        "Mod+T".action = spawn "foot";
        "Super+Alt+L".action = spawn "swaylock";
        "Mod+Q".action = close-window;
        "Mod+Shift+E".action = quit;

        # Regular window launchers (using run-or-raise)
        "Mod+F".action = spawn-sh "run-or-raise com.denis.terminal 'ghostty --class=com.denis.terminal'";
        "Mod+G".action = spawn-sh "run-or-raise google-chrome 'google-chrome-stable'";
        "Mod+S".action = spawn-sh "run-or-raise Slack 'slack'";
        "Mod+B".action = spawn-sh "run-or-raise firefox 'firefox'";

        # Scratchpad window launchers (run-or-raise behavior)
        "Mod+X".action = spawn-sh "run-or-raise com.denis.scratchpad 'foot --app-id com.denis.scratchpad'";
        "Mod+D".action =
          spawn-sh "run-or-raise com.denis.notebook 'foot --app-id com.denis.notebook -e env MODE=notebook nvim -c \"lua require(\\\"dennich\\\").create_weekly_note()\"'";

        # Launchers and tools
        "Mod+Y".action = spawn "fuzzel";
        "Mod+C".action =
          spawn-sh "cliphist list | fuzzel --dmenu --prompt '📋 ' --width 56 | cliphist decode | wl-copy";

        # Screenshots
        "Print".action = screenshot;
        "Alt+Print".action = screenshot-window;
        "Mod+Shift+S".action =
          spawn "bash" "-lc"
            "grim -g \"$(slurp)\" -t ppm - | satty --filename - --fullscreen --output-filename \"$HOME/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H-%M-%S').png\"";

        # Client actions
        "Mod+Ctrl+Space".action = toggle-window-floating;
        "Mod+O".action = move-window-to-monitor-right;
        "Mod+M".action = maximize-column;
        "Mod+Ctrl+M".action = center-column;
        "Mod+Shift+M".action = fullscreen-window;

        # Column tabs toggle (layout switching alternative)
        "Mod+Shift+W".action = spawn-sh "niri msg action toggle-column-tabbed-display || true";

        # Window focus
        "Mod+H".action = focus-column-left;
        "Mod+L".action = focus-column-right;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;
        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;

        # Focus previous window (Alt-Tab equivalent)
        "Mod+Tab".action = spawn-sh "niri msg action focus-window-previous || true";

        # Window movement
        "Mod+Ctrl+H".action = move-column-left;
        "Mod+Ctrl+L".action = move-column-right;
        "Mod+Ctrl+J".action = move-window-down;
        "Mod+Ctrl+K".action = move-window-up;
        "Mod+Ctrl+Left".action = move-column-left;
        "Mod+Ctrl+Right".action = move-column-right;
        "Mod+Ctrl+Down".action = move-window-down;
        "Mod+Ctrl+Up".action = move-window-up;

        # Monitor focus
        "Mod+Shift+H".action = focus-monitor-left;
        "Mod+Shift+L".action = focus-monitor-right;
        "Mod+Shift+J".action = focus-monitor-down;
        "Mod+Shift+K".action = focus-monitor-up;
        "Mod+Shift+Left".action = focus-monitor-left;
        "Mod+Shift+Right".action = focus-monitor-right;
        "Mod+Shift+Down".action = focus-monitor-down;
        "Mod+Shift+Up".action = focus-monitor-up;

        # Move to monitor
        "Mod+Ctrl+Shift+H".action = move-column-to-monitor-left;
        "Mod+Ctrl+Shift+L".action = move-column-to-monitor-right;
        "Mod+Ctrl+Shift+J".action = move-column-to-monitor-down;
        "Mod+Ctrl+Shift+K".action = move-column-to-monitor-up;
        "Mod+Ctrl+Shift+Left".action = move-column-to-monitor-left;
        "Mod+Ctrl+Shift+Right".action = move-column-to-monitor-right;
        "Mod+Ctrl+Shift+Down".action = move-column-to-monitor-down;
        "Mod+Ctrl+Shift+Up".action = move-column-to-monitor-up;

        # Workspaces
        "Mod+U".action = focus-workspace-down;
        "Mod+I".action = focus-workspace-up;
        "Mod+Page_Down".action = focus-workspace-down;
        "Mod+Page_Up".action = focus-workspace-up;

        # Move to workspace
        "Mod+Ctrl+U".action = move-column-to-workspace-down;
        "Mod+Ctrl+I".action = move-column-to-workspace-up;
        "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
        "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;

        # Move workspace
        "Mod+Shift+U".action = move-workspace-down;
        "Mod+Shift+I".action = move-workspace-up;
        "Mod+Shift+Page_Down".action = move-workspace-down;
        "Mod+Shift+Page_Up".action = move-workspace-up;

        # Column management
        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;
        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;

        # Pomodoro launcher (like AwesomeWM)
        "Mod+R".action =
          spawn "foot" "--app-id=com.denis.float" "-e" "${cfg.dennichPkg}/bin/dennich-todo"
            "start-pomodoro";

        # Window sizing (mwfact equivalent) - moved to different key since R is used for pomodoro
        "Mod+Shift+R".action = switch-preset-column-width;
        "Mod+Alt+R".action = switch-preset-window-height;
        "Mod+Ctrl+R".action = reset-window-height;
        "Mod+Minus".action = set-column-width "-5%";
        "Mod+Equal".action = set-column-width "+5%";
        "Mod+Shift+Minus".action = set-window-height "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";

        # Fullscreen and floating
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+V".action = toggle-window-floating;
        "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

        # Audio controls
        "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
        "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
        "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      };
    };
  };
}
