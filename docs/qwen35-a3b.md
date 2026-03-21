# Qwen 3.5 35B-A3B via llama.cpp

Notas do preset local desta maquina.

Modelo padrao:

- Repo GGUF: `bartowski/Qwen_Qwen3.5-35B-A3B-GGUF`
- Quantizacao: `Qwen_Qwen3.5-35B-A3B-IQ4_XS.gguf`
- Caminho local: `/home/fmazzuco/models/qwen/Qwen3.5-35B-A3B-GGUF/Qwen_Qwen3.5-35B-A3B-IQ4_XS.gguf`

Comandos:

- `qwen35-a3b-download`
- `qwen35-a3b-chat`
- `qwen35-a3b-server`
- `systemctl --user status qwen35-a3b-server`
- `systemctl --user restart qwen35-a3b-server`

Preset aplicado para esta RTX 5070 Ti 16 GB:

- `ctx-size=65536`
- `batch-size=1024`
- `ubatch-size=256`
- `flash-attn=on`
- `parallel=1`
- `fit=on`
- `fit-target=256`
- `fit-ctx=4096`
- `cache-type-k=q8_0`
- `cache-type-v=q4_0`
- `threads=12`
- `threads-batch=12`

Overrides uteis:

- `QWEN35_A3B_CTX`
- `QWEN35_A3B_BATCH`
- `QWEN35_A3B_UBATCH`
- `QWEN35_A3B_FIT`
- `QWEN35_A3B_FIT_TARGET`
- `QWEN35_A3B_FIT_CTX`
- `QWEN35_A3B_CACHE_K`
- `QWEN35_A3B_CACHE_V`
- `QWEN35_A3B_THREADS`
- `QWEN35_A3B_THREADS_BATCH`
- `QWEN35_A3B_PARALLEL`
- `QWEN35_A3B_REASONING_BUDGET`
- `QWEN35_A3B_HOST`
- `QWEN35_A3B_PORT`

API local:

- `http://127.0.0.1:8080`

Servico:

- O repo agora declara `systemd.user.services.qwen35-a3b-server`.
- O `35B-A3B` fica para start manual quando voce quiser trocar o modelo padrao.
- Quando iniciado, ele atende em `127.0.0.1:8080` no lugar do preset padrao.
- o preset de servico padrao do modulo usa `thinking-general` via `QWEN35_A3B_PROFILE=thinking-general`.
- Como o `35B-A3B` nao sobe por padrao, ele continua sendo uma troca manual quando voce quiser priorizar qualidade em vez do preset rapido.

Observacoes:

- O preset foi escolhido para equilibrar VRAM, RAM, contexto e latencia nesta maquina.
- Se quiser puxar mais qualidade e aceitar mais lentidao, o proximo teste natural e `Q4_K_M`.
