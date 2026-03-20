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

  qwen35_9BModelDir = "/home/fmazzuco/models/qwen/Qwen3.5-9B-GGUF";
  qwen35_9BModelFile = "${qwen35_9BModelDir}/Qwen_Qwen3.5-9B-IQ4_XS.gguf";

  qwen35_9BDownload = pkgs.writeShellScriptBin "qwen35-9b-download" ''
    set -euo pipefail

    mkdir -p "${qwen35_9BModelDir}"

    exec ${pkgs.python313Packages.huggingface-hub}/bin/hf download \
      bartowski/Qwen_Qwen3.5-9B-GGUF \
      Qwen_Qwen3.5-9B-IQ4_XS.gguf \
      --local-dir "${qwen35_9BModelDir}"
  '';

  qwen35_9BChat = pkgs.writeShellScriptBin "qwen35-9b-chat" ''
    set -euo pipefail

    MODEL_FILE="''${QWEN35_9B_FILE:-${qwen35_9BModelFile}}"
    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo nao encontrado em $MODEL_FILE" >&2
      echo "Rode: qwen35-9b-download" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    PROFILE="''${QWEN35_9B_PROFILE:-instruct-fast}"
    case "$PROFILE" in
      speed|instruct-fast)
        DEFAULT_REASONING_FORMAT="none"
        DEFAULT_REASONING_BUDGET="0"
        DEFAULT_TEMP="0.2"
        DEFAULT_TOP_P="0.85"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="0.0"
        DEFAULT_REPEAT_PENALTY="1.05"
        ;;
      instruct|instruct-general)
        DEFAULT_REASONING_FORMAT="none"
        DEFAULT_REASONING_BUDGET="0"
        DEFAULT_TEMP="0.5"
        DEFAULT_TOP_P="0.9"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="0.0"
        DEFAULT_REPEAT_PENALTY="1.05"
        ;;
      thinking|thinking-general)
        DEFAULT_REASONING_FORMAT="deepseek"
        DEFAULT_REASONING_BUDGET="-1"
        DEFAULT_TEMP="0.6"
        DEFAULT_TOP_P="0.95"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="0.0"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      thinking-coding)
        DEFAULT_REASONING_FORMAT="deepseek"
        DEFAULT_REASONING_BUDGET="-1"
        DEFAULT_TEMP="0.4"
        DEFAULT_TOP_P="0.9"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="0.0"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      *)
        echo "Perfil QWEN35_9B_PROFILE invalido: $PROFILE" >&2
        echo "Use: speed, instruct, instruct-fast, thinking-general ou thinking-coding" >&2
        exit 1
        ;;
    esac

    exec ${llamaCppCuda}/bin/llama-cli \
      --model "$MODEL_FILE" \
      --conversation \
      --jinja \
      --no-prefill-assistant \
      --reasoning-format "''${QWEN35_9B_REASONING_FORMAT:-$DEFAULT_REASONING_FORMAT}" \
      --reasoning-budget "''${QWEN35_9B_REASONING_BUDGET:-$DEFAULT_REASONING_BUDGET}" \
      --temp "''${QWEN35_9B_TEMP:-$DEFAULT_TEMP}" \
      --top-p "''${QWEN35_9B_TOP_P:-$DEFAULT_TOP_P}" \
      --top-k "''${QWEN35_9B_TOP_K:-$DEFAULT_TOP_K}" \
      --min-p "''${QWEN35_9B_MIN_P:-$DEFAULT_MIN_P}" \
      --presence-penalty "''${QWEN35_9B_PRESENCE_PENALTY:-$DEFAULT_PRESENCE_PENALTY}" \
      --repeat-penalty "''${QWEN35_9B_REPEAT_PENALTY:-$DEFAULT_REPEAT_PENALTY}" \
      --ctx-size "''${QWEN35_9B_CTX:-131072}" \
      --batch-size "''${QWEN35_9B_BATCH:-2048}" \
      --ubatch-size "''${QWEN35_9B_UBATCH:-512}" \
      --threads "''${QWEN35_9B_THREADS:-12}" \
      --threads-batch "''${QWEN35_9B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${QWEN35_9B_PARALLEL:-1}" \
      --cache-type-k "''${QWEN35_9B_CACHE_K:-q4_0}" \
      --cache-type-v "''${QWEN35_9B_CACHE_V:-q4_0}" \
      "$@"
  '';

  qwen35_9BServer = pkgs.writeShellScriptBin "qwen35-9b-server" ''
    set -euo pipefail

    MODEL_FILE="''${QWEN35_9B_FILE:-${qwen35_9BModelFile}}"
    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo nao encontrado em $MODEL_FILE" >&2
      echo "Rode: qwen35-9b-download" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    PROFILE="''${QWEN35_9B_PROFILE:-instruct-fast}"
    case "$PROFILE" in
      speed|instruct-fast)
        DEFAULT_REASONING_FORMAT="none"
        DEFAULT_REASONING_BUDGET="0"
        DEFAULT_TEMP="0.2"
        DEFAULT_TOP_P="0.85"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="0.0"
        DEFAULT_REPEAT_PENALTY="1.05"
        ;;
      instruct|instruct-general)
        DEFAULT_REASONING_FORMAT="none"
        DEFAULT_REASONING_BUDGET="0"
        DEFAULT_TEMP="0.5"
        DEFAULT_TOP_P="0.9"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="0.0"
        DEFAULT_REPEAT_PENALTY="1.05"
        ;;
      thinking|thinking-general)
        DEFAULT_REASONING_FORMAT="deepseek"
        DEFAULT_REASONING_BUDGET="-1"
        DEFAULT_TEMP="0.6"
        DEFAULT_TOP_P="0.95"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="0.0"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      thinking-coding)
        DEFAULT_REASONING_FORMAT="deepseek"
        DEFAULT_REASONING_BUDGET="-1"
        DEFAULT_TEMP="0.4"
        DEFAULT_TOP_P="0.9"
        DEFAULT_TOP_K="20"
        DEFAULT_MIN_P="0.0"
        DEFAULT_PRESENCE_PENALTY="0.0"
        DEFAULT_REPEAT_PENALTY="1.0"
        ;;
      *)
        echo "Perfil QWEN35_9B_PROFILE invalido: $PROFILE" >&2
        echo "Use: speed, instruct, instruct-fast, thinking-general ou thinking-coding" >&2
        exit 1
        ;;
    esac

    exec ${llamaCppCuda}/bin/llama-server \
      --model "$MODEL_FILE" \
      --host "''${QWEN35_9B_HOST:-127.0.0.1}" \
      --port "''${QWEN35_9B_PORT:-8080}" \
      --jinja \
      --no-prefill-assistant \
      --reasoning-format "''${QWEN35_9B_REASONING_FORMAT:-$DEFAULT_REASONING_FORMAT}" \
      --reasoning-budget "''${QWEN35_9B_REASONING_BUDGET:-$DEFAULT_REASONING_BUDGET}" \
      --temp "''${QWEN35_9B_TEMP:-$DEFAULT_TEMP}" \
      --top-p "''${QWEN35_9B_TOP_P:-$DEFAULT_TOP_P}" \
      --top-k "''${QWEN35_9B_TOP_K:-$DEFAULT_TOP_K}" \
      --min-p "''${QWEN35_9B_MIN_P:-$DEFAULT_MIN_P}" \
      --presence-penalty "''${QWEN35_9B_PRESENCE_PENALTY:-$DEFAULT_PRESENCE_PENALTY}" \
      --repeat-penalty "''${QWEN35_9B_REPEAT_PENALTY:-$DEFAULT_REPEAT_PENALTY}" \
      --ctx-size "''${QWEN35_9B_CTX:-131072}" \
      --batch-size "''${QWEN35_9B_BATCH:-2048}" \
      --ubatch-size "''${QWEN35_9B_UBATCH:-512}" \
      --threads "''${QWEN35_9B_THREADS:-12}" \
      --threads-batch "''${QWEN35_9B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${QWEN35_9B_PARALLEL:-1}" \
      --cache-type-k "''${QWEN35_9B_CACHE_K:-q4_0}" \
      --cache-type-v "''${QWEN35_9B_CACHE_V:-q4_0}" \
      "$@"
  '';
in
{
  environment.systemPackages = [
    llamaCppCuda
    pkgs.python313Packages.huggingface-hub
    qwen35_9BDownload
    qwen35_9BChat
    qwen35_9BServer
  ];

  systemd.user.services.qwen35-9b-server = {
    description = "Qwen 3.5 9B local OpenAI-compatible server";
    conflicts = [ "qwen35-a3b-server.service" ];
    serviceConfig = {
      Environment = [
        "QWEN35_9B_PROFILE=instruct-fast"
        "QWEN35_9B_CTX=131072"
      ];
      ExecStart = "${qwen35_9BServer}/bin/qwen35-9b-server";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "/home/fmazzuco";
    };
  };
}
