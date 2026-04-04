{
  pkgs,
  inputs,
  config,
  ...
}:
let
  ai = import ./common.nix { inherit pkgs inputs config; };

  modelsRoot = "${ai.userHome}/models/gemma4";

  gemma4_26BModelDir = "${modelsRoot}/gemma-4-26B-A4B-it-GGUF";
  gemma4_26BModelFile = "${gemma4_26BModelDir}/gemma-4-26B-A4B-it-UD-IQ4_XS.gguf";

  gemma4_26BDownload = ai.mkDownloadScript {
    name = "gemma4-26b-download";
    modelDir = gemma4_26BModelDir;
    repo = "unsloth/gemma-4-26B-A4B-it-GGUF";
    file = "gemma-4-26B-A4B-it-UD-IQ4_XS.gguf";
  };

  gemma4_26BChat = pkgs.writeShellScriptBin "gemma4-26b-chat" ''
    set -euo pipefail

    MODEL_FILE="''${GEMMA4_26B_FILE:-${gemma4_26BModelFile}}"
    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo nao encontrado em $MODEL_FILE" >&2
      echo "Rode: gemma4-26b-download" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    exec ${ai.llamaCppCuda}/bin/llama-cli \
      --model "$MODEL_FILE" \
      --conversation \
      --jinja \
      --reasoning on \
      --reasoning-format deepseek \
      --reasoning-budget "''${GEMMA4_26B_REASONING_BUDGET:--1}" \
      --temp "''${GEMMA4_26B_TEMP:-0.7}" \
      --top-p "''${GEMMA4_26B_TOP_P:-0.9}" \
      --top-k "''${GEMMA4_26B_TOP_K:-40}" \
      --min-p "''${GEMMA4_26B_MIN_P:-0.0}" \
      --repeat-penalty "''${GEMMA4_26B_REPEAT_PENALTY:-1.05}" \
      --ctx-size "''${GEMMA4_26B_CTX:-68000}" \
      --batch-size "''${GEMMA4_26B_BATCH:-2048}" \
      --ubatch-size "''${GEMMA4_26B_UBATCH:-512}" \
      --threads "''${GEMMA4_26B_THREADS:-12}" \
      --threads-batch "''${GEMMA4_26B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${GEMMA4_26B_PARALLEL:-1}" \
      --cache-type-k "''${GEMMA4_26B_CACHE_K:-f16}" \
      --cache-type-v "''${GEMMA4_26B_CACHE_V:-f16}" \
      "$@"
  '';

  gemma4_26BServer = pkgs.writeShellScriptBin "gemma4-26b-server" ''
    set -euo pipefail

    MODEL_FILE="''${GEMMA4_26B_FILE:-${gemma4_26BModelFile}}"
    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo nao encontrado em $MODEL_FILE" >&2
      echo "Rode: gemma4-26b-download" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    exec ${ai.llamaCppCuda}/bin/llama-server \
      --model "$MODEL_FILE" \
      --host "''${GEMMA4_26B_HOST:-127.0.0.1}" \
      --port "''${GEMMA4_26B_PORT:-18083}" \
      --jinja \
      --reasoning on \
      --reasoning-format deepseek \
      --reasoning-budget "''${GEMMA4_26B_REASONING_BUDGET:--1}" \
      --temp "''${GEMMA4_26B_TEMP:-0.7}" \
      --top-p "''${GEMMA4_26B_TOP_P:-0.9}" \
      --top-k "''${GEMMA4_26B_TOP_K:-40}" \
      --min-p "''${GEMMA4_26B_MIN_P:-0.0}" \
      --repeat-penalty "''${GEMMA4_26B_REPEAT_PENALTY:-1.05}" \
      --ctx-size "''${GEMMA4_26B_CTX:-68000}" \
      --batch-size "''${GEMMA4_26B_BATCH:-2048}" \
      --ubatch-size "''${GEMMA4_26B_UBATCH:-512}" \
      --threads "''${GEMMA4_26B_THREADS:-12}" \
      --threads-batch "''${GEMMA4_26B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${GEMMA4_26B_PARALLEL:-1}" \
      --cache-type-k "''${GEMMA4_26B_CACHE_K:-f16}" \
      --cache-type-v "''${GEMMA4_26B_CACHE_V:-f16}" \
      "$@"
  '';
in
{
  environment.systemPackages = [
    gemma4_26BDownload
    gemma4_26BChat
    gemma4_26BServer
  ];

  systemd.user.services.gemma4-26b-server = ai.mkUserService {
    description = "Gemma 4 26B local OpenAI-compatible server";
    conflicts = [
      "qwen35-9b-server.service"
      "gemma4-e4b-server.service"
      "gemma4-31b-server.service"
    ];
    environment = [
      "GEMMA4_26B_CTX=68000"
      "GEMMA4_26B_CACHE_K=f16"
      "GEMMA4_26B_CACHE_V=f16"
    ];
    execStart = "${gemma4_26BServer}/bin/gemma4-26b-server";
  };
}
