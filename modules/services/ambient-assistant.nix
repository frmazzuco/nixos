{ pkgs, config, ... }:
let
  assistantRepo = "${config.workstation.repoRoot}/ambient-assistant";
in
{
  systemd.user.services.ambient-assistant = {
    description = "Ambient Assistant — local context-aware AI service";
    wantedBy = [ "default.target" ];
    path = [ pkgs.ripgrep pkgs.curl pkgs.git ];
    serviceConfig = {
      Environment = [
        "AMBIENT_ASSISTANT_HOST=127.0.0.1"
        "AMBIENT_ASSISTANT_PORT=8765"
        "AMBIENT_ASSISTANT_PROVIDER_KIND=openai-api"
        "AMBIENT_ASSISTANT_MODEL=gpt-5.4-nano"
        "AMBIENT_ASSISTANT_PROFILE=thinking-general"
        "AMBIENT_ASSISTANT_MAX_TOOL_ROUNDS=24"
      ];
      ExecStart = "${pkgs.python313}/bin/python3 -m ambient_assistant serve";
      WorkingDirectory = assistantRepo;
      Restart = "on-failure";
      RestartSec = 3;
    };
    environment = {
      PYTHONPATH = "${assistantRepo}/src";
    };
  };
}
