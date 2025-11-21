{
  lib,
  config,
  ...
}:
let
  defaultOpencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    plugin = [ "opencode-openai-codex-auth" ];
    provider = {
      openai = {
        options = {
          reasoningEffort = "medium";
          reasoningSummary = "auto";
          textVerbosity = "medium";
          include = [ "reasoning.encrypted_content" ];
          store = false;
        };
        models = {
          "gpt-5-codex-low" = {
            name = "GPT 5 Codex Low (OAuth)";
            options = {
              reasoningEffort = "low";
              reasoningSummary = "auto";
              textVerbosity = "medium";
              include = [ "reasoning.encrypted_content" ];
              store = false;
            };
          };
          "gpt-5-codex-medium" = {
            name = "GPT 5 Codex Medium (OAuth)";
            options = {
              reasoningEffort = "medium";
              reasoningSummary = "auto";
              textVerbosity = "medium";
              include = [ "reasoning.encrypted_content" ];
              store = false;
            };
          };
          "gpt-5-codex-high" = {
            name = "GPT 5 Codex High (OAuth)";
            options = {
              reasoningEffort = "high";
              reasoningSummary = "detailed";
              textVerbosity = "medium";
              include = [ "reasoning.encrypted_content" ];
              store = false;
            };
          };
          "gpt-5-minimal" = {
            name = "GPT 5 Minimal (OAuth)";
            options = {
              reasoningEffort = "minimal";
              reasoningSummary = "auto";
              textVerbosity = "low";
              include = [ "reasoning.encrypted_content" ];
              store = false;
            };
          };
          "gpt-5-low" = {
            name = "GPT 5 Low (OAuth)";
            options = {
              reasoningEffort = "low";
              reasoningSummary = "auto";
              textVerbosity = "low";
              include = [ "reasoning.encrypted_content" ];
              store = false;
            };
          };
          "gpt-5-medium" = {
            name = "GPT 5 Medium (OAuth)";
            options = {
              reasoningEffort = "medium";
              reasoningSummary = "auto";
              textVerbosity = "medium";
              include = [ "reasoning.encrypted_content" ];
              store = false;
            };
          };
          "gpt-5-high" = {
            name = "GPT 5 High (OAuth)";
            options = {
              reasoningEffort = "high";
              reasoningSummary = "detailed";
              textVerbosity = "high";
              include = [ "reasoning.encrypted_content" ];
              store = false;
            };
          };
          "gpt-5-mini" = {
            name = "GPT 5 Mini (OAuth)";
            options = {
              reasoningEffort = "low";
              reasoningSummary = "auto";
              textVerbosity = "low";
              include = [ "reasoning.encrypted_content" ];
              store = false;
            };
          };
          "gpt-5-nano" = {
            name = "GPT 5 Nano (OAuth)";
            options = {
              reasoningEffort = "minimal";
              reasoningSummary = "auto";
              textVerbosity = "low";
              include = [ "reasoning.encrypted_content" ];
              store = false;
            };
          };
        };
      };
    };
  };
in
{
  options.codingAgents = {
    enable = lib.mkEnableOption "setup OpenCode configuration";
    opencodeConfig = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = defaultOpencodeConfig;
      description = "Attrset that will be turned into the OpenCode JSON config.";
    };
  };

  config = lib.mkIf config.codingAgents.enable {
    xdg.configFile."opencode/opencode.json".text = builtins.toJSON config.codingAgents.opencodeConfig;
  };
}
