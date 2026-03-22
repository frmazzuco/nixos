{ pkgs, ... }:
{
  systemd.user.services.ambient-assistant = {
    description = "Ambient Assistant — local context-aware AI service";
    wantedBy = [ "default.target" ];
    wants = [ "qwen35-9b-server.service" ];
    after = [ "qwen35-9b-server.service" ];
    partOf = [ "qwen35-9b-server.service" ];
    serviceConfig = {
      Environment = [
        "AMBIENT_ASSISTANT_HOST=127.0.0.1"
        "AMBIENT_ASSISTANT_PORT=8765"
        "AMBIENT_ASSISTANT_PROVIDER_BASE_URL=http://127.0.0.1:8080/v1"
        "AMBIENT_ASSISTANT_MODEL=qwen35-9b"
        "AMBIENT_ASSISTANT_PROFILE=thinking-general"
      ];
      ExecStart = "${pkgs.python313}/bin/python3 -m ambient_assistant serve";
      WorkingDirectory = "/home/fmazzuco/repos/ambient-assistant";
      Restart = "on-failure";
      RestartSec = 3;
    };
    environment = {
      PYTHONPATH = "/home/fmazzuco/repos/ambient-assistant/src";
    };
  };
}
