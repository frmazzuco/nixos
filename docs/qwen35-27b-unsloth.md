# Qwen 3.5 27B Unsloth via llama.cpp

Preset local do `IQ4_XS` para esta RTX 5070 Ti 16 GB.

Modelo padrao:

- Repo GGUF: `unsloth/Qwen3.5-27B-GGUF`
- Quantizacao: `Qwen3.5-27B-IQ4_XS.gguf`
- Caminho local: `/home/fmazzuco/models/qwen/Qwen3.5-27B-GGUF/Qwen3.5-27B-IQ4_XS.gguf`

Comandos:

- `qwen35-27b-download`
- `qwen35-27b-chat`
- `qwen35-27b-server`
- `systemctl --user start qwen35-27b-server`
- `systemctl --user stop qwen35-27b-server`
- `systemctl --user status qwen35-27b-server`

Preset inicial desta maquina:

- `ctx-size=8192`
- `batch-size=1024`
- `ubatch-size=256`
- `flash-attn=on`
- `parallel=1`
- `fit=on`
- `fit-target=256`
- `fit-ctx=4096`
- `cache-type-k=q4_0`
- `cache-type-v=q4_0`
- `threads=12`
- `threads-batch=12`
- `profile=instruct-fast`
- `port=8082`

Overrides uteis:

- `QWEN35_27B_CTX`
- `QWEN35_27B_BATCH`
- `QWEN35_27B_UBATCH`
- `QWEN35_27B_FIT`
- `QWEN35_27B_FIT_TARGET`
- `QWEN35_27B_FIT_CTX`
- `QWEN35_27B_CACHE_K`
- `QWEN35_27B_CACHE_V`
- `QWEN35_27B_THREADS`
- `QWEN35_27B_THREADS_BATCH`
- `QWEN35_27B_PARALLEL`
- `QWEN35_27B_PROFILE`
- `QWEN35_27B_REASONING_BUDGET`
- `QWEN35_27B_HOST`
- `QWEN35_27B_PORT`

Observacoes:

- O `27B` nao deve ficar ativo junto com o `9B` ou o `35B-A3B` na mesma GPU.
- O `IQ4_XS` foi escolhido para priorizar encaixe de VRAM e latencia melhor que `Q4_K_M`.
- O endpoint padrao do server ficou em `127.0.0.1:8082` para nao disputar a porta `8080` do setup atual.

API local:

- `http://127.0.0.1:8082`
