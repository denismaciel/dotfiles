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
      ignores = [
        ".aws"
        ".direnv"
        ".envrc"
        ".gcloud"
        ".llm"
        ".mise.toml"
        "__pycache__"
        "play"
        "track"
        "track-core.md"
        "venv"
      ];
      settings = {
        user = {
          name = "Denis Maciel";
          email = "denispmaciel@gmail.com";
        };
        alias = {
          last = "for-each-ref --sort=-committerdate --count=20 --format='%(align:70,left)%(refname:short)%(end)%(committerdate:relative)' refs/heads/";
          lastco = "!git last | fzf | awk '{print $1}' | xargs git checkout";
          please = "push origin HEAD --force-with-lease";
        };
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
