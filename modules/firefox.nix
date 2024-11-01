{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options = {
    firefox.enable = lib.mkEnableOption "enables firefox";
  };
  config = lib.mkIf config.go.enable {
    stylix.targets.firefox.enable = false;
    programs.firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayMenuBar = "never"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified";
        PasswordManagerEnabled = false;
      };
      profiles.default = {
        userChrome = builtins.readFile ../userChrome.css;
        settings = {
          "apz.overscroll.enabled" = true;
          "browser.aboutConfig.showWarning" = false;
          "general.autoScroll" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        bookmarks = [
          {
            name = "wikipedia";
            tags = ["wiki"];
            keyword = "wiki";
            url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&amp;go=Go";
          }
          {
            name = "Samwise PRs";
            keyword = "sam";
            url = "https://github.com/monasticventures/samwise/pulls";
          }
          {
            name = "Hacker News Search";
            tags = ["news" "tech"];
            keyword = "hn";
            url = "https://hn.algolia.com/?q=%s";
          }
        ];
        extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
          ublock-origin
          vimium-c
          darkreader
          multi-account-containers
        ];
      };
    };
  };
}
