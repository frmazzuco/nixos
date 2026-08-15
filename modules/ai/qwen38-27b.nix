{
  pkgs,
  inputs,
  config,
  ...
}:
let
  ai = import ./common.nix { inherit pkgs inputs config; };
  ports = import ./ports.nix;

  qwen38_27BModelDir = "${ai.modelsRoot}/Qwen3.8-27B-GGUF";
  qwen38_27BModelFile = "${qwen38_27BModelDir}/Qwen3.8-27B-UD-Q3_K_XL.gguf";

  qwen38_27BDownload = ai.mkDownloadScript {
    name = "qwen38-27b-download";
    modelDir = qwen38_27BModelDir;
    repo = "unsloth/Qwen3.8-27B-GGUF";
    file = "Qwen3.8-27B-UD-Q3_K_XL.gguf";
  };

  qwen38_27BChat = pkgs.writeShellScriptBin "qwen38-27b-chat" ''
    set -euo pipefail

    MODEL_FILE="''${QWEN38_27B_FILE:-${qwen38_27BModelFile}}"
    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo não encontrado em $MODEL_FILE" >&2
      echo "Rode: qwen38-27b-download" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    PROFILE="''${QWEN38_27B_PROFILE:-thinking-general}"
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
        echo "Perfil QWEN38_27B_PROFILE inválido: $PROFILE" >&2
        echo "Use: speed, instruct, instruct-fast, thinking-general ou thinking-coding" >&2
        exit 1
        ;;
    esac

    exec ${ai.llamaCppCuda}/bin/llama-cli \
      --model "$MODEL_FILE" \
      --conversation \
      --jinja \
      --no-prefill-assistant \
      --reasoning-format "''${QWEN38_27B_REASONING_FORMAT:-$DEFAULT_REASONING_FORMAT}" \
      --reasoning-budget "''${QWEN38_27B_REASONING_BUDGET:-$DEFAULT_REASONING_BUDGET}" \
      --temp "''${QWEN38_27B_TEMP:-$DEFAULT_TEMP}" \
      --top-p "''${QWEN38_27B_TOP_P:-$DEFAULT_TOP_P}" \
      --top-k "''${QWEN38_27B_TOP_K:-$DEFAULT_TOP_K}" \
      --min-p "''${QWEN38_27B_MIN_P:-$DEFAULT_MIN_P}" \
      --presence-penalty "''${QWEN38_27B_PRESENCE_PENALTY:-$DEFAULT_PRESENCE_PENALTY}" \
      --repeat-penalty "''${QWEN38_27B_REPEAT_PENALTY:-$DEFAULT_REPEAT_PENALTY}" \
      --ctx-size "''${QWEN38_27B_CTX:-102400}" \
      --batch-size "''${QWEN38_27B_BATCH:-2048}" \
      --ubatch-size "''${QWEN38_27B_UBATCH:-512}" \
      --threads "''${QWEN38_27B_THREADS:-12}" \
      --threads-batch "''${QWEN38_27B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${QWEN38_27B_PARALLEL:-1}" \
      --cache-type-k "''${QWEN38_27B_CACHE_K:-q4_0}" \
      --cache-type-v "''${QWEN38_27B_CACHE_V:-q4_0}" \
      "$@"
  '';

  qwen38_27BServer = pkgs.writeShellScriptBin "qwen38-27b-server" ''
    set -euo pipefail

    MODEL_FILE="''${QWEN38_27B_FILE:-${qwen38_27BModelFile}}"
    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo não encontrado em $MODEL_FILE" >&2
      echo "Rode: qwen38-27b-download" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    PROFILE="''${QWEN38_27B_PROFILE:-thinking-general}"
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
        echo "Perfil QWEN38_27B_PROFILE inválido: $PROFILE" >&2
        echo "Use: speed, instruct, instruct-fast, thinking-general ou thinking-coding" >&2
        exit 1
        ;;
    esac

    exec ${ai.llamaCppCuda}/bin/llama-server \
      --model "$MODEL_FILE" \
      --alias "qwen3.8-27b-ud-q3-k-xl" \
      --host "''${QWEN38_27B_HOST:-127.0.0.1}" \
      --port "''${QWEN38_27B_PORT:-${toString ports."qwen38-27b"}}" \
      --jinja \
      --no-prefill-assistant \
      --cache-prompt \
      --reasoning-format "''${QWEN38_27B_REASONING_FORMAT:-$DEFAULT_REASONING_FORMAT}" \
      --reasoning-budget "''${QWEN38_27B_REASONING_BUDGET:-$DEFAULT_REASONING_BUDGET}" \
      --temp "''${QWEN38_27B_TEMP:-$DEFAULT_TEMP}" \
      --top-p "''${QWEN38_27B_TOP_P:-$DEFAULT_TOP_P}" \
      --top-k "''${QWEN38_27B_TOP_K:-$DEFAULT_TOP_K}" \
      --min-p "''${QWEN38_27B_MIN_P:-$DEFAULT_MIN_P}" \
      --presence-penalty "''${QWEN38_27B_PRESENCE_PENALTY:-$DEFAULT_PRESENCE_PENALTY}" \
      --repeat-penalty "''${QWEN38_27B_REPEAT_PENALTY:-$DEFAULT_REPEAT_PENALTY}" \
      --ctx-size "''${QWEN38_27B_CTX:-102400}" \
      --batch-size "''${QWEN38_27B_BATCH:-2048}" \
      --ubatch-size "''${QWEN38_27B_UBATCH:-512}" \
      --threads "''${QWEN38_27B_THREADS:-12}" \
      --threads-batch "''${QWEN38_27B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${QWEN38_27B_PARALLEL:-1}" \
      --cache-type-k "''${QWEN38_27B_CACHE_K:-q4_0}" \
      --cache-type-v "''${QWEN38_27B_CACHE_V:-q4_0}" \
      --fit off \
      --n-gpu-layers all \
      "$@"
  '';
in
{
  environment.systemPackages = [
    ai.llamaCppCuda
    ai.huggingfaceHub
    qwen38_27BDownload
    qwen38_27BChat
    qwen38_27BServer
  ];

  systemd.user.services.qwen38-27b-server = ai.mkUserService {
    description = "Qwen 3.8 27B local OpenAI-compatible server";
    conflicts = [
      "qwen35-9b-server.service"
      "gemma4-e4b-server.service"
      "gemma4-26b-server.service"
      "gemma4-31b-server.service"
    ];
    wantedBy = [ "default.target" ];
    environment = [
      "QWEN38_27B_PROFILE=thinking-general"
      "QWEN38_27B_CTX=102400"
      "QWEN38_27B_BATCH=2048"
      "QWEN38_27B_UBATCH=512"
      "QWEN38_27B_CACHE_K=q4_0"
      "QWEN38_27B_CACHE_V=q4_0"
    ];
    execStart = "${qwen38_27BServer}/bin/qwen38-27b-server";
  };
}
