# Gemma 4 31B via llama.cpp

Preset local do `Gemma 4 31B` para esta RTX 5070 Ti 16 GB.

Modelo padrao:

- Repo GGUF: `unsloth/gemma-4-31B-it-GGUF`
- Quantizacao padrao: `gemma-4-31B-it-Q4_K_M.gguf` (`GEMMA4_31B_QUANT=q4km`)
- Quantizacao alternativa: `gemma-4-31B-it-Q4_K_S.gguf` (`GEMMA4_31B_QUANT=q4ks`)
- Caminho local: `/home/fmazzuco/models/gemma4/gemma-4-31B-it-GGUF/gemma-4-31B-it-Q4_K_M.gguf`

Comandos:

- `gemma4-31b-download-q4km`
- `gemma4-31b-download-q4ks`
- `gemma4-31b-chat`
- `gemma4-31b-server`
- `systemctl --user status gemma4-31b-server`
- `systemctl --user start gemma4-31b-server`
- `systemctl --user stop gemma4-31b-server`

Preset aplicado para esta RTX 5070 Ti 16 GB:

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
- `host=127.0.0.1`
- `port=8084`

Overrides uteis:

- `GEMMA4_31B_QUANT` (`q4km` padrao, `q4ks` alternativa)
- `GEMMA4_31B_FILE`
- `GEMMA4_31B_CTX`
- `GEMMA4_31B_BATCH`
- `GEMMA4_31B_UBATCH`
- `GEMMA4_31B_THREADS`
- `GEMMA4_31B_THREADS_BATCH`
- `GEMMA4_31B_PARALLEL`
- `GEMMA4_31B_FIT`
- `GEMMA4_31B_FIT_TARGET`
- `GEMMA4_31B_FIT_CTX`
- `GEMMA4_31B_CACHE_K`
- `GEMMA4_31B_CACHE_V`
- `GEMMA4_31B_TEMP`
- `GEMMA4_31B_TOP_P`
- `GEMMA4_31B_TOP_K`
- `GEMMA4_31B_MIN_P`
- `GEMMA4_31B_REPEAT_PENALTY`
- `GEMMA4_31B_HOST`
- `GEMMA4_31B_PORT`

API local:

- `http://127.0.0.1:8084`

Observacoes:

- O servico de usuario `gemma4-31b-server` e um preset manual (nao sobe por padrao na sessao do usuario); inicie `systemctl --user start gemma4-31b-server` quando precisar do endpoint local.
- O servico declara `Conflicts` com o `qwen35-9b-server.service`, entao iniciar um derruba o outro na mesma GPU.
- O servidor escuta por padrao em `127.0.0.1` na porta `8084`.
- A quantizacao padrao do wrapper e do servico e `Q4_K_M` via `GEMMA4_31B_QUANT=q4km`; para usar a `Q4_K_S`, baixe com `gemma4-31b-download-q4ks` e rode com `GEMMA4_31B_QUANT=q4ks`.
- O preset usa `fit=on` com `fit-target=256` e `fit-ctx=4096` para o llama.cpp ajustar o offload dentro da VRAM desta GPU.
- O KV cache fica em `cache-type-k=q4_0` e `cache-type-v=q4_0` para caber o `31B` denso nesta GPU.
- O `ctx-size=8192` e o default conservador deste preset; se houver folga de VRAM, aumente via `GEMMA4_31B_CTX`.
