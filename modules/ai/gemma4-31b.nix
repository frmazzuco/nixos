{
  pkgs,
  inputs,
  config,
  ...
}:
let
  ai = import ./common.nix { inherit pkgs inputs config; };

  modelsRoot = "${ai.userHome}/models/gemma4";

  gemma4_31BModelDir = "${modelsRoot}/gemma-4-31B-it-GGUF";
  gemma4_31BModelFileQ4KM = "${gemma4_31BModelDir}/gemma-4-31B-it-Q4_K_M.gguf";
  gemma4_31BModelFileQ4KS = "${gemma4_31BModelDir}/gemma-4-31B-it-Q4_K_S.gguf";

  gemma4_31BDownloadQ4KM = ai.mkDownloadScript {
    name = "gemma4-31b-download-q4km";
    modelDir = gemma4_31BModelDir;
    repo = "unsloth/gemma-4-31B-it-GGUF";
    file = "gemma-4-31B-it-Q4_K_M.gguf";
  };

  gemma4_31BDownloadQ4KS = ai.mkDownloadScript {
    name = "gemma4-31b-download-q4ks";
    modelDir = gemma4_31BModelDir;
    repo = "unsloth/gemma-4-31B-it-GGUF";
    file = "gemma-4-31B-it-Q4_K_S.gguf";
  };

  gemma4_31BChat = pkgs.writeShellScriptBin "gemma4-31b-chat" ''
    set -euo pipefail

    QUANT="''${GEMMA4_31B_QUANT:-q4km}"
    case "$QUANT" in
      q4km) MODEL_FILE="''${GEMMA4_31B_FILE:-${gemma4_31BModelFileQ4KM}}" ;;
      q4ks) MODEL_FILE="''${GEMMA4_31B_FILE:-${gemma4_31BModelFileQ4KS}}" ;;
      *) echo "GEMMA4_31B_QUANT invalido: $QUANT (use q4km ou q4ks)" >&2; exit 1 ;;
    esac

    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo nao encontrado em $MODEL_FILE" >&2
      echo "Rode: gemma4-31b-download-q4km ou gemma4-31b-download-q4ks" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    exec ${ai.llamaCppCuda}/bin/llama-cli \
      --model "$MODEL_FILE" \
      --conversation \
      --jinja \
      --temp "''${GEMMA4_31B_TEMP:-0.7}" \
      --top-p "''${GEMMA4_31B_TOP_P:-0.9}" \
      --top-k "''${GEMMA4_31B_TOP_K:-40}" \
      --min-p "''${GEMMA4_31B_MIN_P:-0.0}" \
      --repeat-penalty "''${GEMMA4_31B_REPEAT_PENALTY:-1.05}" \
      --ctx-size "''${GEMMA4_31B_CTX:-8192}" \
      --batch-size "''${GEMMA4_31B_BATCH:-1024}" \
      --ubatch-size "''${GEMMA4_31B_UBATCH:-256}" \
      --threads "''${GEMMA4_31B_THREADS:-12}" \
      --threads-batch "''${GEMMA4_31B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${GEMMA4_31B_PARALLEL:-1}" \
      --fit "''${GEMMA4_31B_FIT:-on}" \
      --fit-target "''${GEMMA4_31B_FIT_TARGET:-256}" \
      --fit-ctx "''${GEMMA4_31B_FIT_CTX:-4096}" \
      --cache-type-k "''${GEMMA4_31B_CACHE_K:-q4_0}" \
      --cache-type-v "''${GEMMA4_31B_CACHE_V:-q4_0}" \
      "$@"
  '';

  gemma4_31BServer = pkgs.writeShellScriptBin "gemma4-31b-server" ''
    set -euo pipefail

    QUANT="''${GEMMA4_31B_QUANT:-q4km}"
    case "$QUANT" in
      q4km) MODEL_FILE="''${GEMMA4_31B_FILE:-${gemma4_31BModelFileQ4KM}}" ;;
      q4ks) MODEL_FILE="''${GEMMA4_31B_FILE:-${gemma4_31BModelFileQ4KS}}" ;;
      *) echo "GEMMA4_31B_QUANT invalido: $QUANT (use q4km ou q4ks)" >&2; exit 1 ;;
    esac

    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo nao encontrado em $MODEL_FILE" >&2
      echo "Rode: gemma4-31b-download-q4km ou gemma4-31b-download-q4ks" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    exec ${ai.llamaCppCuda}/bin/llama-server \
      --model "$MODEL_FILE" \
      --host "''${GEMMA4_31B_HOST:-127.0.0.1}" \
      --port "''${GEMMA4_31B_PORT:-8084}" \
      --jinja \
      --temp "''${GEMMA4_31B_TEMP:-0.7}" \
      --top-p "''${GEMMA4_31B_TOP_P:-0.9}" \
      --top-k "''${GEMMA4_31B_TOP_K:-40}" \
      --min-p "''${GEMMA4_31B_MIN_P:-0.0}" \
      --repeat-penalty "''${GEMMA4_31B_REPEAT_PENALTY:-1.05}" \
      --ctx-size "''${GEMMA4_31B_CTX:-8192}" \
      --batch-size "''${GEMMA4_31B_BATCH:-1024}" \
      --ubatch-size "''${GEMMA4_31B_UBATCH:-256}" \
      --threads "''${GEMMA4_31B_THREADS:-12}" \
      --threads-batch "''${GEMMA4_31B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${GEMMA4_31B_PARALLEL:-1}" \
      --fit "''${GEMMA4_31B_FIT:-on}" \
      --fit-target "''${GEMMA4_31B_FIT_TARGET:-256}" \
      --fit-ctx "''${GEMMA4_31B_FIT_CTX:-4096}" \
      --cache-type-k "''${GEMMA4_31B_CACHE_K:-q4_0}" \
      --cache-type-v "''${GEMMA4_31B_CACHE_V:-q4_0}" \
      "$@"
  '';
in
{
  environment.systemPackages = [
    gemma4_31BDownloadQ4KM
    gemma4_31BDownloadQ4KS
    gemma4_31BChat
    gemma4_31BServer
  ];

  systemd.user.services.gemma4-31b-server = ai.mkUserService {
    description = "Gemma 4 31B local OpenAI-compatible server";
    conflicts = [ "qwen35-9b-server.service" ];
    environment = [ "GEMMA4_31B_QUANT=q4km" ];
    execStart = "${gemma4_31BServer}/bin/gemma4-31b-server";
  };
}
