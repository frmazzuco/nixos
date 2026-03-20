# Qwen 3.5 9B via llama.cpp

Preset local focado em velocidade nesta RTX 5070 Ti 16 GB.

Modelo padrao:

- Repo GGUF: `bartowski/Qwen_Qwen3.5-9B-GGUF`
- Quantizacao: `Qwen_Qwen3.5-9B-IQ4_XS.gguf`
- Caminho local: `/home/fmazzuco/models/qwen/Qwen3.5-9B-GGUF/Qwen_Qwen3.5-9B-IQ4_XS.gguf`

Comandos:

- `qwen35-9b-download`
- `qwen35-9b-chat`
- `qwen35-9b-server`
- `systemctl --user start qwen35-9b-server`
- `systemctl --user stop qwen35-9b-server`
- `systemctl --user status qwen35-9b-server`

Preset aplicado para esta RTX 5070 Ti 16 GB:

- `ctx-size=8192`
- `batch-size=2048`
- `ubatch-size=512`
- `flash-attn=on`
- `parallel=1`
- `cache-type-k=q4_0`
- `cache-type-v=q4_0`
- `threads=12`
- `threads-batch=12`
- `profile=instruct-fast`

Benchmark local resumido nesta RTX 5070 Ti 16 GB:

- `Q4_K_M` com `q8_0/q4_0`: cerca de `105 tok/s` em `tg128`
- `IQ4_XS` com `q8_0/q4_0`: cerca de `118 tok/s` em `tg128`
- `IQ4_XS` com `q4_0/q4_0`: cerca de `124 tok/s` em `tg128`

Contexto longo:

- `QWEN35_9B_CTX=131072` para `128k`
- Para `128k`, manter `QWEN35_9B_CACHE_K=q4_0` e `QWEN35_9B_CACHE_V=q4_0`
- Validado localmente em `127.0.0.1:8081` com uso de GPU na casa de `6.4 GiB` em idle apos carga

Perfis:

- `speed` ou `instruct-fast`: raciocinio desativado, latencia minima.
- `instruct`: sem raciocinio, um pouco mais solto na amostragem.
- `thinking-general`: habilita raciocinio.
- `thinking-coding`: habilita raciocinio com sampling mais fechado.

Overrides uteis:

- `QWEN35_9B_CTX`
- `QWEN35_9B_BATCH`
- `QWEN35_9B_UBATCH`
- `QWEN35_9B_THREADS`
- `QWEN35_9B_THREADS_BATCH`
- `QWEN35_9B_PARALLEL`
- `QWEN35_9B_CACHE_K`
- `QWEN35_9B_CACHE_V`
- `QWEN35_9B_PROFILE`
- `QWEN35_9B_REASONING_BUDGET`
- `QWEN35_9B_HOST`
- `QWEN35_9B_PORT`

API local:

- `http://127.0.0.1:8080`

Observacoes:

- O `35B-A3B` e o `9B` podem coexistir instalados, mas nao devem ficar ativos juntos na GPU. Os servicos tem `Conflicts=` para garantir isso.
- O `9B` foi deixado com contexto menor por padrao para reduzir custo de prefill e manter a resposta mais rapida.
- O melhor ponto de velocidade medido ate agora foi `IQ4_XS` com KV em `q4_0/q4_0`.
- Se quiser abrir um endpoint paralelo em outra porta, rode o binario manualmente com `QWEN35_9B_PORT=8081 qwen35-9b-server`, mas pare o `35B-A3B` antes.
