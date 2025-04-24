{
  config,
  lib,
  pkgs,
  ...
}: {
  # Based off `ghostty +show-config --default --docs`
  xdg.configFile."ghostty/config".text = ''
    font-family = Blex Mono Nerd Font
    font-style = Medium
    font-size = 13
    font-thicken = false

    adjust-cell-height = 15%

    theme = zenwritten_dark
    selection-invert-fg-bg = false
    minimum-contrast = 1

    cursor-opacity = 1
    cursor-style = block
    cursor-style-blink = false
    cursor-click-to-move = true

    mouse-hide-while-typing = false
    mouse-shift-capture = false
    mouse-scroll-multiplier = 1

    background-opacity = 1
    background-blur-radius = 10
    unfocused-split-opacity = 0.6

    # The color to dim the unfocused split. Unfocused splits are dimmed by
    # rendering a semi-transparent rectangle over the split. This sets the color of
    # that rectangle and can be used to carefully control the dimming effect.
    #
    # This will default to the background color.
    unfocused-split-fill =
    command = zsh -l

    wait-after-command = false
    # in bytes:
    scrollback-limit = 10000000
    link-url = true
    fullscreen = true
    title =
    working-directory = home

    window-padding-x = 5
    window-padding-y = 5
    window-padding-balance = true
    window-padding-color = extend-always
    window-vsync = true
    window-inherit-working-directory = true
    window-inherit-font-size = true

    window-decoration = false
    window-title-font-family = Inter
    window-theme = auto
    window-save-state = default
    window-new-tab-position = current

    focus-follows-mouse = false
    gtk-titlebar = false

    # Whether to allow programs running in the terminal to read/write to the
    # system clipboard (OSC 52, for googling). The default is to allow clipboard
    # reading after prompting the user and allow writing unconditionally.
    clipboard-read = ask

    clipboard-write = allow
    # Trims trailing whitespace on data that is copied to the clipboard. This does
    # not affect data sent to the clipboard via `clipboard-write`.
    clipboard-trim-trailing-spaces = true

    # Require confirmation before pasting text that appears unsafe. This helps
    # prevent a "copy/paste attack" where a user may accidentally execute unsafe
    # commands by pasting text with newlines.
    clipboard-paste-protection = true

    # If true, bracketed pastes will be considered safe. By default, bracketed
    # pastes are considered safe. "Bracketed" pastes are pastes while the running
    # program has bracketed paste mode enabled (a setting set by the running
    # program, not the terminal emulator).
    clipboard-paste-bracketed-safe = true

    # The total amount of bytes that can be used for image data (i.e. the Kitty
    # image protocol) per terminal scren. The maximum value is 4,294,967,295
    # (4GiB). The default is 320MB. If this is set to zero, then all image
    # protocols will be disabled.
    #
    # This value is separate for primary and alternate screens so the effective
    # limit per surface is double.
    image-storage-limit = 320000000

    # Whether to automatically copy selected text to the clipboard. `true` will
    # only copy on systems that support a selection clipboard.
    #
    # The value `clipboard` will copy to the system clipboard, making this work on
    # macOS. Note that middle-click will also paste from the system clipboard in
    # this case.
    #
    # Note that if this is disabled, middle-click paste will also be disabled.
    copy-on-select = true

    # The time in milliseconds between clicks to consider a click a repeat
    # (double, triple, etc.) or an entirely new single click. A value of zero will
    # use a platform-specific default. The default on macOS is determined by the
    # OS settings. On every other platform it is 500ms.
    click-repeat-interval = 0

    # Additional configuration files to read. This configuration can be repeated
    # to read multiple configuration files. Configuration files themselves can
    # load more configuration files. Paths are relative to the file containing the
    # `config-file` directive. For command-line arguments, paths are relative to
    # the current working directory.
    #
    # Cycles are not allowed. If a cycle is detected, an error will be logged and
    # the configuration file will be ignored.
    config-file =

    # Confirms that a surface should be closed before closing it. This defaults to
    # true. If set to false, surfaces will close without any confirmation.
    confirm-close-surface = false

    # Whether or not to quit after the last window is closed. This defaults to
    # false. Currently only supported on macOS. On Linux, the process always exits
    # after the last window is closed.
    quit-after-last-window-closed = false

    shell-integration = zsh
    shell-integration-features = no-cursor,no-sudo,no-title

    custom-shader-animation = false
    macos-non-native-fullscreen = false
    macos-titlebar-style = transparent
    macos-option-as-alt = true
    macos-window-shadow = true

    gtk-single-instance = desktop
    gtk-tabs-location = top
    gtk-wide-tabs = false

    gtk-adwaita = true

    desktop-notifications = true
    bold-is-bright = false

    term = xterm-ghostty

    keybind = ctrl+enter=toggle_fullscreen
  '';
}
