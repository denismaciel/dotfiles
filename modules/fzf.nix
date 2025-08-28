{ lib, ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultOptions = [
      "--height 100%"
      "--reverse"
      "--border"
      "--ansi"
      "--multi"
      "--preview-window=right:70%"
    ];

    # Default command from _zshrc (with typo fix)
    defaultCommand = "rg --files --no-ignore-vcs --ignore-file ~/.ripgrep_ignore";

    # File widget command
    fileWidgetCommand = "rg --files --no-ignore-vcs --ignore-file ~/.ripgrep_ignore";

    # Directory widget options
    changeDirWidgetOptions = [
      "--preview 'ls -la {}'"
    ];

    # History widget options
    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };

  # Shell functions that depend on fzf
  programs.zsh.initContent = lib.mkAfter ''
    # fzf completion functions from _zshrc
    function _fzf_compgen_dir() {
      fd --type d --hidden --follow --exclude ".git" --exclude "venv" . "$1"
    }

    function _fzf_compgen_path() {
      fd --hidden --follow --exclude ".git" --exclude "venv" . "$1"
    }

    # fzf helper function
    function fzf-down() {
      fzf --height 50% "$@" --border
    }
  '';
}
