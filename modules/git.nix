{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    git.enable = lib.mkEnableOption "enables git configuration";
  };
  config = lib.mkIf config.git.enable {
    programs.git = {
      enable = true;
      userName = "Denis Maciel";
      userEmail = "denispmaciel@gmail.com";
      ignores = [
        ".DS_Store"
        ".avante_chat_history"
        ".direnv"
        ".envrc"
        ".llm"
        ".mypy_cache"
        ".pytest_cache"
        ".python-version"
        ".vim"
        ".vscode"
        "__pycache__"
        "play"
        "snaps"
        "t.py"
        "tags"
        "track-core.md"
        "venv"
        ".mise.toml"
      ];
      aliases = {
        last = "for-each-ref --sort=-committerdate --count=20 --format='%(align:70,left)%(refname:short)%(end)%(committerdate:relative)' refs/heads/";
        lastco = "!git last | fzf | awk '{print $1}' | xargs git checkout";
        please = "push origin HEAD --force-with-lease";
      };
      extraConfig = {
        diff = {
          tool = "difftastic";
        };
        difftool = {
          prompt = false;
        };
        difftool.difftastic = {
          cmd = "difft \"$LOCAL\" \"$REMOTE\"";
        };
        pager = {
          difftool = true;
        };
        fetch = {
          prune = true;
        };
        "background-fetch" = {
          enabled = true;
          interval = 300; # fetch every 5 minutes
        };
      };
    };
    home.packages = with pkgs; [
      difftastic
      scmpuff
    ];
  };
}
