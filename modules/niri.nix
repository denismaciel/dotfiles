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
    home.packages = [
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

      (pkgs.writeShellScriptBin "toggle-notebook" ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Toggle the floating Vim notebook scratchpad between the active workspace and a stash workspace.
        APP_ID="com.denis.notebook"
        CMD="foot --app-id com.denis.notebook -e env MODE=notebook nvim -c \"lua require('dennich').create_weekly_note()\""
        NIRI="${pkgs.niri}/bin/niri"
        JQ="${pkgs.jq}/bin/jq"

        windows_json="$($NIRI msg -j windows 2>/dev/null || echo '[]')"
        workspaces_json="$($NIRI msg -j workspaces 2>/dev/null || echo '[]')"
        focused_window_json="$($NIRI msg -j focused-window 2>/dev/null || echo '{}')"

        notebook_info="$(echo "$windows_json" | $JQ -c --arg id "$APP_ID" 'map(select(.app_id==$id)) | first')"

        if [ -z "$notebook_info" ] || [ "$notebook_info" = "null" ]; then
          exec sh -lc "$CMD"
        fi

        focused_workspace_id="$(echo "$focused_window_json" | $JQ -r '.workspace_id // empty')"
        if [ -z "$focused_workspace_id" ]; then
          focused_workspace_id="$(echo "$workspaces_json" | $JQ -r '(map(select(.is_focused == true)) | first | .id) // empty')"
        fi
        if [ -z "$focused_workspace_id" ]; then
          focused_workspace_id="$(echo "$workspaces_json" | $JQ -r '(first(.[]?).id) // 1')"
        fi
        if ! [[ "$focused_workspace_id" =~ ^[0-9]+$ ]]; then
          focused_workspace_id="1"
        fi

        focused_workspace_idx="$(echo "$workspaces_json" | $JQ -r --argjson ws_id "$focused_workspace_id" '(map(select(.id == $ws_id)) | first | .idx) // 1')"
        stash_idx="$(echo "$workspaces_json" | $JQ -r 'if length == 0 then 1 else (map(.idx) | max) end')"

        if ! [[ "$focused_workspace_idx" =~ ^[0-9]+$ ]]; then
          focused_workspace_idx="1"
        fi
        if ! [[ "$stash_idx" =~ ^[0-9]+$ ]]; then
          stash_idx="$focused_workspace_idx"
        fi
        if [ "$stash_idx" = "$focused_workspace_idx" ]; then
          stash_idx=$((focused_workspace_idx + 1))
        fi

        notebook_id="$(echo "$notebook_info" | $JQ -r '.id')"
        notebook_workspace_id="$(echo "$notebook_info" | $JQ -r '.workspace_id')"
        notebook_is_focused="$(echo "$notebook_info" | $JQ -r '.is_focused')"

        if [ "$notebook_workspace_id" != "$focused_workspace_id" ]; then
          $NIRI msg action move-window-to-workspace "$focused_workspace_idx" --window-id "$notebook_id" --focus=false
          $NIRI msg action move-window-to-floating --id "$notebook_id"
          $NIRI msg action focus-window --id "$notebook_id"
          $NIRI msg action center-window --id "$notebook_id"
          exit 0
        fi

        if [ "$notebook_is_focused" = "true" ]; then
          $NIRI msg action focus-window-previous || true
          $NIRI msg action move-window-to-workspace "$stash_idx" --window-id "$notebook_id" --focus=false
          exit 0
        fi

        $NIRI msg action move-window-to-floating --id "$notebook_id"
        $NIRI msg action focus-window --id "$notebook_id"
        $NIRI msg action center-window --id "$notebook_id"
      '')

      (pkgs.writeShellScriptBin "toggle-scratchpad" ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Toggle the floating terminal scratchpad between the active workspace and a stash workspace.
        APP_ID="com.denis.scratchpad"
        CMD="foot --app-id com.denis.scratchpad --override main.initial-window-size-pixels=1000x1000"
        NIRI="${pkgs.niri}/bin/niri"
        JQ="${pkgs.jq}/bin/jq"
        TARGET_SIZE=1000
        SIZE_CHANGE="$TARGET_SIZE"

        windows_json="$($NIRI msg -j windows 2>/dev/null || echo '[]')"
        workspaces_json="$($NIRI msg -j workspaces 2>/dev/null || echo '[]')"
        focused_window_json="$($NIRI msg -j focused-window 2>/dev/null || echo '{}')"

        scratchpad_info="$(echo "$windows_json" | $JQ -c --arg id "$APP_ID" 'map(select(.app_id==$id)) | first')"

        if [ -z "$scratchpad_info" ] || [ "$scratchpad_info" = "null" ]; then
          exec sh -lc "$CMD"
        fi

        focused_workspace_id="$(echo "$focused_window_json" | $JQ -r '.workspace_id // empty')"
        if [ -z "$focused_workspace_id" ]; then
          focused_workspace_id="$(echo "$workspaces_json" | $JQ -r '(map(select(.is_focused == true)) | first | .id) // empty')"
        fi
        if [ -z "$focused_workspace_id" ]; then
          focused_workspace_id="$(echo "$workspaces_json" | $JQ -r '(first(.[]?).id) // 1')"
        fi
        if ! [[ "$focused_workspace_id" =~ ^[0-9]+$ ]]; then
          focused_workspace_id="1"
        fi

        focused_workspace_idx="$(echo "$workspaces_json" | $JQ -r --argjson ws_id "$focused_workspace_id" '(map(select(.id == $ws_id)) | first | .idx) // 1')"
        stash_idx="$(echo "$workspaces_json" | $JQ -r 'if length == 0 then 1 else (map(.idx) | max) end')"

        if ! [[ "$focused_workspace_idx" =~ ^[0-9]+$ ]]; then
          focused_workspace_idx="1"
        fi
        if ! [[ "$stash_idx" =~ ^[0-9]+$ ]]; then
          stash_idx="$focused_workspace_idx"
        fi
        if [ "$stash_idx" = "$focused_workspace_idx" ]; then
          stash_idx=$((focused_workspace_idx + 1))
        fi

        scratchpad_id="$(echo "$scratchpad_info" | $JQ -r '.id')"
        scratchpad_workspace_id="$(echo "$scratchpad_info" | $JQ -r '.workspace_id')"
        scratchpad_is_focused="$(echo "$scratchpad_info" | $JQ -r '.is_focused')"

        if [ "$scratchpad_workspace_id" != "$focused_workspace_id" ]; then
          $NIRI msg action move-window-to-workspace "$focused_workspace_idx" --window-id "$scratchpad_id" --focus=false
          $NIRI msg action move-window-to-floating --id "$scratchpad_id"
          $NIRI msg action set-window-width "$SIZE_CHANGE" --id "$scratchpad_id" || true
          $NIRI msg action set-window-height "$SIZE_CHANGE" --id "$scratchpad_id" || true
          $NIRI msg action focus-window --id "$scratchpad_id"
          $NIRI msg action center-window --id "$scratchpad_id"
          exit 0
        fi

        if [ "$scratchpad_is_focused" = "true" ]; then
          $NIRI msg action focus-window-previous || true
          $NIRI msg action move-window-to-workspace "$stash_idx" --window-id "$scratchpad_id" --focus=false
          exit 0
        fi

        $NIRI msg action move-window-to-floating --id "$scratchpad_id"
        $NIRI msg action set-window-width "$SIZE_CHANGE" --id "$scratchpad_id" || true
        $NIRI msg action set-window-height "$SIZE_CHANGE" --id "$scratchpad_id" || true
        $NIRI msg action focus-window --id "$scratchpad_id"
        $NIRI msg action center-window --id "$scratchpad_id"
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

          modules-left = [
            "niri/workspaces"
            "tray"
          ];
          modules-center = [ "niri/window" ];
          modules-right = [
            "custom/pomodoro"
            "custom/media"
            "custom/audio-selector"
            "network"
            "memory"
            "cpu"
            "disk"
            "battery"
            "clock"
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
            format-disconnected = "⚠";
          };

          memory = {
            interval = 2;
            format = "󰍛 {percentage:02}%";
          };

          cpu = {
            interval = 2;
            format = "󰻠 {usage:02}%";
          };

          disk = {
            interval = 25;
            format = "󰋊 {percentage_used:02}%";
            path = "/";
          };

          battery = {
            format = "󰁹 {capacity:02}% {icon}";
            format-charging = "󰂄 {capacity:02}% {icon}";
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

          "custom/audio-selector" = {
            format = "󰓃";
            tooltip-format = "Click to select audio device";
            on-click = "${pkgs.writeShellScript "audio-selector" ''
              #!/usr/bin/env bash

              # Function to get and select audio sinks (outputs)
              select_output() {
                # Get list of sinks with descriptions
                sinks=$(${pkgs.wireplumber}/bin/wpctl status | awk '/Audio/,/Video/ {if (/Sinks:/) flag=1; else if (/Sources:/ || /Video/) flag=0; if (flag && /\│/ && /\[vol:/) print}' | sed 's/[│├└]//g' | sed 's/^[ \t]*//')
                
                # Format for fuzzel and get selection
                selected=$(echo "$sinks" | while IFS= read -r line; do
                  id=$(echo "$line" | awk '{print $1}' | sed 's/[.*]//g')
                  name=$(echo "$line" | sed 's/^[0-9]*\. *//; s/ *\[vol:.*\]//')
                  active=$(echo "$line" | grep -q '\*' && echo "[ACTIVE]" || echo "")
                  echo "$id: $name $active"
                done | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Select Audio Output: " --width 60)
                
                if [ -n "$selected" ]; then
                  sink_id=$(echo "$selected" | cut -d: -f1)
                  ${pkgs.wireplumber}/bin/wpctl set-default "$sink_id"
                fi
              }

              # Function to get and select audio sources (inputs)
              select_input() {
                # Get list of sources with descriptions
                sources=$(${pkgs.wireplumber}/bin/wpctl status | awk '/Sources:/,/Sink endpoints:/ {if (/Sources:/) flag=1; else if (/Sink endpoints:/) flag=0; if (flag && /\│/ && /\[vol:/) print}' | sed 's/[│├└]//g' | sed 's/^[ \t]*//')
                
                # Format for fuzzel and get selection
                selected=$(echo "$sources" | while IFS= read -r line; do
                  id=$(echo "$line" | awk '{print $1}' | sed 's/[.*]//g')
                  name=$(echo "$line" | sed 's/^[0-9]*\. *//; s/ *\[vol:.*\]//')
                  active=$(echo "$line" | grep -q '\*' && echo "[ACTIVE]" || echo "")
                  echo "$id: $name $active"
                done | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Select Audio Input: " --width 60)
                
                if [ -n "$selected" ]; then
                  source_id=$(echo "$selected" | cut -d: -f1)
                  ${pkgs.wireplumber}/bin/wpctl set-default "$source_id"
                fi
              }

              # Main menu
              choice=$(echo -e "Audio Output (Speakers/Headphones)\nAudio Input (Microphone)" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Select Device Type: " --width 40)

              case "$choice" in
                "Audio Output"*) select_output ;;
                "Audio Input"*) select_input ;;
              esac
            ''}";
            interval = "once";
          };

          "custom/media" = {
            format = "{icon} {}";
            return-type = "json";
            max-length = 40;
            format-icons = {
              spotify = "";
              default = "♪";
            };
            escape = true;
            exec = "${pkgs.writeShellScript "waybar-media" ''
              #!/usr/bin/env bash
              # Get volume info
              volume=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%02d", int($2*100)}')
              volume_text="$volume%"

              player_status=$(${pkgs.playerctl}/bin/playerctl status 2>/dev/null)
              if [ "$player_status" = "Playing" ]; then
                title=$(${pkgs.playerctl}/bin/playerctl metadata title 2>/dev/null || echo "Unknown")
                artist=$(${pkgs.playerctl}/bin/playerctl metadata artist 2>/dev/null || echo "Unknown")
                player=$(${pkgs.playerctl}/bin/playerctl metadata --format '{{ lc(playerName) }}' 2>/dev/null || echo "default")
                echo "{\"text\":\"$artist - $title | $volume_text\",\"class\":\"playing\",\"alt\":\"$player\"}"
              elif [ "$player_status" = "Paused" ]; then
                title=$(${pkgs.playerctl}/bin/playerctl metadata title 2>/dev/null || echo "Paused")
                artist=$(${pkgs.playerctl}/bin/playerctl metadata artist 2>/dev/null || echo "")
                player=$(${pkgs.playerctl}/bin/playerctl metadata --format '{{ lc(playerName) }}' 2>/dev/null || echo "default")
                echo "{\"text\":\"$artist - $title | $volume_text\",\"class\":\"paused\",\"alt\":\"$player\"}"
              else
                echo "{\"text\":\"$volume_text\",\"class\":\"stopped\",\"alt\":\"none\"}"
              fi
            ''}";
            on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
            on-click-right = "${pkgs.playerctl}/bin/playerctl next";
            on-click-middle = "${pkgs.playerctl}/bin/playerctl previous";
            on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
            on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            interval = 2;
          };
        };
      };

      style = ''
        * {
          font-family: "BlexMono Nerd Font Mono";
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
          background-color: transparent;
          padding: 0 15px;
          margin: 0 5px;
        }

        #clock,
        #battery,
        #network,
        #memory,
        #cpu,
        #disk,
        #tray,
        #custom-media,
        #custom-audio-selector {
          padding: 0 10px;
          margin: 0 2px;
          background-color: transparent;
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
          background-color: transparent;
          color: #cdd6f4;
        }

        #custom-pomodoro.pomodoro-idle {
          background-color: transparent;
          color: #cdd6f4;
        }

        #custom-pomodoro.pomodoro-idle-blink {
          background-color: #f38ba8;
          color: #1e1e2e;
        }

        /* Media control styles */
        #custom-media.playing {
          background-color: transparent;
          color: #94e2d5;
        }

        #custom-media.paused {
          background-color: transparent;
          color: #f9e2af;
        }

        #custom-media.stopped {
          background-color: transparent;
          color: #6c7086;
        }

        /* Audio selector styles */
        #custom-audio-selector {
          color: #89b4fa;
        }

        #custom-audio-selector:hover {
          background-color: rgba(69, 71, 90, 0.8);
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

        # Preset column widths for equal split
        preset-column-widths = [
          { proportion = 0.5; } # 50% width - equal split
          { proportion = 0.33333; } # One third
          { proportion = 0.66667; } # Two thirds
        ];

        # Default to first preset (50%)
        default-column-width = {
          proportion = 0.5;
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

        # Floating scratchpad terminal sizing
        {
          matches = [ { app-id = "^com\\.denis\\.scratchpad$"; } ];
          open-floating = true;
          default-column-width = {
            fixed = 1000;
          };
          default-window-height = {
            fixed = 1000;
          };
        }

        {
          matches = [ { app-id = "^com\\.denis\\.notebook$"; } ];
          open-floating = true;
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

        # Scratchpad window launchers
        "Mod+X".action = spawn "toggle-scratchpad";
        "Mod+D".action = spawn "toggle-notebook";

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
