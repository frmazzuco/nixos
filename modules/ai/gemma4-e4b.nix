{
  pkgs,
  inputs,
  config,
  ...
}:
let
  ai = import ./common.nix { inherit pkgs inputs config; };

  modelsRoot = "${ai.userHome}/models/gemma4";

  gemma4_E4BModelDir = "${modelsRoot}/gemma-4-E4B-it-GGUF";
  gemma4_E4BModelFile = "${gemma4_E4BModelDir}/gemma-4-e4b-it-Q8_0.gguf";

  gemma4_E4BDownload = ai.mkDownloadScript {
    name = "gemma4-e4b-download";
    modelDir = gemma4_E4BModelDir;
    repo = "ggml-org/gemma-4-E4B-it-GGUF";
    file = "gemma-4-e4b-it-Q8_0.gguf";
  };

  gemma4_E4BChat = pkgs.writeShellScriptBin "gemma4-e4b-chat" ''
    set -euo pipefail

    MODEL_FILE="''${GEMMA4_E4B_FILE:-${gemma4_E4BModelFile}}"
    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo nao encontrado em $MODEL_FILE" >&2
      echo "Rode: gemma4-e4b-download" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    exec ${ai.llamaCppCuda}/bin/llama-cli \
      --model "$MODEL_FILE" \
      --conversation \
      --jinja \
      --temp "''${GEMMA4_E4B_TEMP:-0.6}" \
      --top-p "''${GEMMA4_E4B_TOP_P:-0.95}" \
      --top-k "''${GEMMA4_E4B_TOP_K:-64}" \
      --min-p "''${GEMMA4_E4B_MIN_P:-0.0}" \
      --repeat-penalty "''${GEMMA4_E4B_REPEAT_PENALTY:-1.0}" \
      --ctx-size "''${GEMMA4_E4B_CTX:-131072}" \
      --batch-size "''${GEMMA4_E4B_BATCH:-2048}" \
      --ubatch-size "''${GEMMA4_E4B_UBATCH:-512}" \
      --threads "''${GEMMA4_E4B_THREADS:-12}" \
      --threads-batch "''${GEMMA4_E4B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${GEMMA4_E4B_PARALLEL:-1}" \
      --cache-type-k "''${GEMMA4_E4B_CACHE_K:-f16}" \
      --cache-type-v "''${GEMMA4_E4B_CACHE_V:-f16}" \
      --reasoning on \
      --reasoning-format deepseek \
      --reasoning-budget "''${GEMMA4_E4B_REASONING_BUDGET:--1}" \
      "$@"
  '';

  gemma4_E4BServer = pkgs.writeShellScriptBin "gemma4-e4b-server" ''
    set -euo pipefail

    MODEL_FILE="''${GEMMA4_E4B_FILE:-${gemma4_E4BModelFile}}"
    if [ ! -f "$MODEL_FILE" ]; then
      echo "Modelo nao encontrado em $MODEL_FILE" >&2
      echo "Rode: gemma4-e4b-download" >&2
      exit 1
    fi

    export CUDA_VISIBLE_DEVICES="''${CUDA_VISIBLE_DEVICES:-0}"

    exec ${ai.llamaCppCuda}/bin/llama-server \
      --model "$MODEL_FILE" \
      --host "''${GEMMA4_E4B_HOST:-127.0.0.1}" \
      --port "''${GEMMA4_E4B_PORT:-18083}" \
      --jinja \
      --temp "''${GEMMA4_E4B_TEMP:-0.6}" \
      --top-p "''${GEMMA4_E4B_TOP_P:-0.95}" \
      --top-k "''${GEMMA4_E4B_TOP_K:-64}" \
      --min-p "''${GEMMA4_E4B_MIN_P:-0.0}" \
      --repeat-penalty "''${GEMMA4_E4B_REPEAT_PENALTY:-1.0}" \
      --ctx-size "''${GEMMA4_E4B_CTX:-131072}" \
      --batch-size "''${GEMMA4_E4B_BATCH:-2048}" \
      --ubatch-size "''${GEMMA4_E4B_UBATCH:-512}" \
      --threads "''${GEMMA4_E4B_THREADS:-12}" \
      --threads-batch "''${GEMMA4_E4B_THREADS_BATCH:-12}" \
      --flash-attn on \
      --parallel "''${GEMMA4_E4B_PARALLEL:-1}" \
      --cache-type-k "''${GEMMA4_E4B_CACHE_K:-f16}" \
      --cache-type-v "''${GEMMA4_E4B_CACHE_V:-f16}" \
      --reasoning on \
      --reasoning-format deepseek \
      --reasoning-budget "''${GEMMA4_E4B_REASONING_BUDGET:--1}" \
      "$@"
  '';
in
{
  environment.systemPackages = [
    gemma4_E4BDownload
    gemma4_E4BChat
    gemma4_E4BServer
  ];

  systemd.user.services.gemma4-e4b-server = ai.mkUserService {
    description = "Gemma 4 E4B local OpenAI-compatible server";
    conflicts = [
      "qwen35-9b-server.service"
      "gemma4-26b-server.service"
      "gemma4-31b-server.service"
    ];
    wantedBy = [ "default.target" ];
    environment = [
      "GEMMA4_E4B_CTX=131072"
      "GEMMA4_E4B_CACHE_K=f16"
      "GEMMA4_E4B_CACHE_V=f16"
    ];
    execStart = "${gemma4_E4BServer}/bin/gemma4-e4b-server";
  };
}
