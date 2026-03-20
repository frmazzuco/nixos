{ pkgs, inputs, ... }:
let
  unstablePackages = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  llamaCppCuda =
    (unstablePackages.llama-cpp.override {
      cudaSupport = true;
    }).overrideAttrs
      (old: {
        cmakeFlags =
          builtins.filter (flag: (builtins.match ".*CMAKE_CUDA_ARCHITECTURES.*" flag) == null) (
            old.cmakeFlags or [ ]
          )
          ++ [ "-DCMAKE_CUDA_ARCHITECTURES=120" ];
      });

  qwen35A3BModelDir = "/home/fmazzuco/models/qwen/Qwen3.5-35B-A3B-GGUF";
  qwen35A3BModelFile = "${qwen35A3BModelDir}/Qwen_Qwen3.5-35B-A3B-IQ4_XS.gguf";

  qwen35A3BDownload = pkgs.writeShellScriptBin "qwen35-a3b-download" ''
    set -euo pipefail

    mkdir -p "${qwen35A3BModelDir}"

    exec ${pkgs.python313Packages.huggingface-hub}/bin/hf download \
      bartowski/Qwen_Qwen3.5-35B-A3B-GGUF \
      Qwen_Qwen3.5-35B-A3B-IQ4_XS.gguf \
      --local-dir "${qwen35A3BModelDir}"
  '';

  qwen35A3BChat = pkgs.writeShellScriptBin "qwen35-a3b-chat" ''
    set -euo pipefail

    MODEL_FILE="''${QWEN35_A3B_FILE:-${qwen35A3BModelFile}}"
    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo nao encontrado em $MODEL_FILE" >&2
      echo "Rode: qwen35-a3b-download" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    PROFILE="''${QWEN35_A3B_PROFILE:-instruct}"
    case "$PROFILE" in
      thinking|thinking-general)
        DEFAULT_REASONING_FORMAT="deepseek"
        DEFAULT_REASONING_BUDGET="-1"
        DEFAULT_TEMP="1.0"
        DEFAULT_TOP_P="0.95"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="1.5"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      thinking-coding)
        DEFAULT_REASONING_FORMAT="deepseek"
        DEFAULT_REASONING_BUDGET="-1"
        DEFAULT_TEMP="0.6"
        DEFAULT_TOP_P="0.95"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="0.0"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      instruct-reasoning)
        DEFAULT_REASONING_FORMAT="none"
        DEFAULT_REASONING_BUDGET="0"
        DEFAULT_TEMP="1.0"
        DEFAULT_TOP_P="0.95"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="1.5"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      instruct|instruct-general)
        DEFAULT_REASONING_FORMAT="none"
        DEFAULT_REASONING_BUDGET="0"
        DEFAULT_TEMP="0.7"
        DEFAULT_TOP_P="0.8"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="1.5"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      *)
        echo "Perfil QWEN35_A3B_PROFILE invalido: $PROFILE" >&2
        echo "Use: instruct, instruct-reasoning, thinking-general ou thinking-coding" >&2
        exit 1
        ;;
    esac

    exec ${llamaCppCuda}/bin/llama-cli \
      --model "$MODEL_FILE" \
      --conversation \
      --jinja \
      --no-prefill-assistant \
      --reasoning-format "''${QWEN35_A3B_REASONING_FORMAT:-$DEFAULT_REASONING_FORMAT}" \
      --reasoning-budget "''${QWEN35_A3B_REASONING_BUDGET:-$DEFAULT_REASONING_BUDGET}" \
      --temp "''${QWEN35_A3B_TEMP:-$DEFAULT_TEMP}" \
      --top-p "''${QWEN35_A3B_TOP_P:-$DEFAULT_TOP_P}" \
      --top-k "''${QWEN35_A3B_TOP_K:-$DEFAULT_TOP_K}" \
      --min-p "''${QWEN35_A3B_MIN_P:-$DEFAULT_MIN_P}" \
      --presence-penalty "''${QWEN35_A3B_PRESENCE_PENALTY:-$DEFAULT_PRESENCE_PENALTY}" \
      --repeat-penalty "''${QWEN35_A3B_REPEAT_PENALTY:-$DEFAULT_REPEAT_PENALTY}" \
      --ctx-size "''${QWEN35_A3B_CTX:-65536}" \
      --batch-size "''${QWEN35_A3B_BATCH:-1024}" \
      --ubatch-size "''${QWEN35_A3B_UBATCH:-256}" \
      --threads "''${QWEN35_A3B_THREADS:-12}" \
      --threads-batch "''${QWEN35_A3B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${QWEN35_A3B_PARALLEL:-1}" \
      --fit "''${QWEN35_A3B_FIT:-on}" \
      --fit-target "''${QWEN35_A3B_FIT_TARGET:-256}" \
      --fit-ctx "''${QWEN35_A3B_FIT_CTX:-4096}" \
      --cache-type-k "''${QWEN35_A3B_CACHE_K:-q8_0}" \
      --cache-type-v "''${QWEN35_A3B_CACHE_V:-q4_0}" \
      "$@"
  '';

  qwen35A3BServer = pkgs.writeShellScriptBin "qwen35-a3b-server" ''
    set -euo pipefail

    MODEL_FILE="''${QWEN35_A3B_FILE:-${qwen35A3BModelFile}}"
    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo nao encontrado em $MODEL_FILE" >&2
      echo "Rode: qwen35-a3b-download" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    PROFILE="''${QWEN35_A3B_PROFILE:-instruct}"
    case "$PROFILE" in
      thinking|thinking-general)
        DEFAULT_REASONING_FORMAT="deepseek"
        DEFAULT_REASONING_BUDGET="-1"
        DEFAULT_TEMP="1.0"
        DEFAULT_TOP_P="0.95"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="1.5"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      thinking-coding)
        DEFAULT_REASONING_FORMAT="deepseek"
        DEFAULT_REASONING_BUDGET="-1"
        DEFAULT_TEMP="0.6"
        DEFAULT_TOP_P="0.95"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="0.0"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      instruct-reasoning)
        DEFAULT_REASONING_FORMAT="none"
        DEFAULT_REASONING_BUDGET="0"
        DEFAULT_TEMP="1.0"
        DEFAULT_TOP_P="0.95"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="1.5"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      instruct|instruct-general)
        DEFAULT_REASONING_FORMAT="none"
        DEFAULT_REASONING_BUDGET="0"
        DEFAULT_TEMP="0.7"
        DEFAULT_TOP_P="0.8"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="1.5"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      *)
        echo "Perfil QWEN35_A3B_PROFILE invalido: $PROFILE" >&2
        echo "Use: instruct, instruct-reasoning, thinking-general ou thinking-coding" >&2
        exit 1
        ;;
    esac

    exec ${llamaCppCuda}/bin/llama-server \
      --model "$MODEL_FILE" \
      --host "''${QWEN35_A3B_HOST:-127.0.0.1}" \
      --port "''${QWEN35_A3B_PORT:-8080}" \
      --jinja \
      --no-prefill-assistant \
      --reasoning-format "''${QWEN35_A3B_REASONING_FORMAT:-$DEFAULT_REASONING_FORMAT}" \
      --reasoning-budget "''${QWEN35_A3B_REASONING_BUDGET:-$DEFAULT_REASONING_BUDGET}" \
      --temp "''${QWEN35_A3B_TEMP:-$DEFAULT_TEMP}" \
      --top-p "''${QWEN35_A3B_TOP_P:-$DEFAULT_TOP_P}" \
      --top-k "''${QWEN35_A3B_TOP_K:-$DEFAULT_TOP_K}" \
      --min-p "''${QWEN35_A3B_MIN_P:-$DEFAULT_MIN_P}" \
      --presence-penalty "''${QWEN35_A3B_PRESENCE_PENALTY:-$DEFAULT_PRESENCE_PENALTY}" \
      --repeat-penalty "''${QWEN35_A3B_REPEAT_PENALTY:-$DEFAULT_REPEAT_PENALTY}" \
      --ctx-size "''${QWEN35_A3B_CTX:-65536}" \
      --batch-size "''${QWEN35_A3B_BATCH:-1024}" \
      --ubatch-size "''${QWEN35_A3B_UBATCH:-256}" \
      --threads "''${QWEN35_A3B_THREADS:-12}" \
      --threads-batch "''${QWEN35_A3B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${QWEN35_A3B_PARALLEL:-1}" \
      --fit "''${QWEN35_A3B_FIT:-on}" \
      --fit-target "''${QWEN35_A3B_FIT_TARGET:-256}" \
      --fit-ctx "''${QWEN35_A3B_FIT_CTX:-4096}" \
      --cache-type-k "''${QWEN35_A3B_CACHE_K:-q8_0}" \
      --cache-type-v "''${QWEN35_A3B_CACHE_V:-q4_0}" \
      "$@"
  '';
in
{
  environment.systemPackages = [
    llamaCppCuda
    pkgs.python313Packages.huggingface-hub
    qwen35A3BDownload
    qwen35A3BChat
    qwen35A3BServer
  ];

  systemd.user.services.qwen35-a3b-server = {
    description = "Qwen 3.5 35B A3B local OpenAI-compatible server";
    conflicts = [
      "qwen35-9b-server.service"
      "qwen35-27b-server.service"
    ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Environment = [ "QWEN35_A3B_PROFILE=thinking-general" ];
      ExecStart = "${qwen35A3BServer}/bin/qwen35-a3b-server";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "/home/fmazzuco";
    };
  };
}
