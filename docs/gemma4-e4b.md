# Gemma 4 E4B via llama.cpp

Preset local do `Gemma 4 E4B` validado nesta RTX 5070 Ti 16 GB.

Modelo padrao:

- Repo GGUF: `ggml-org/gemma-4-E4B-it-GGUF`
- Quantizacao: `gemma-4-e4b-it-Q8_0.gguf`
- Caminho local: `/home/fmazzuco/models/gemma4/gemma-4-E4B-it-GGUF/gemma-4-e4b-it-Q8_0.gguf`

Comandos:

- `gemma4-e4b-download`
- `gemma4-e4b-chat`
- `gemma4-e4b-server`
- `systemctl --user status gemma4-e4b-server`
- `systemctl --user start gemma4-e4b-server`
- `systemctl --user stop gemma4-e4b-server`

Preset aplicado para esta RTX 5070 Ti 16 GB:

- `ctx-size=131072`
- `batch-size=2048`
- `ubatch-size=512`
- `flash-attn=on`
- `parallel=1`
- `cache-type-k=f16`
- `cache-type-v=f16`
- `threads=12`
- `threads-batch=12`
- `port=18083`

Benchmark local resumido nesta RTX 5070 Ti 16 GB:

- `20` prompt tokens, `3` completion tokens: `Prompt 331.3 t/s`, `Generation 76.3 t/s`
- `855` prompt tokens, `128` completion tokens: `Prompt 5147.4 t/s`, `Generation 110.6 t/s`
- `32015` prompt tokens, `16` completion tokens: `Prompt 6963.1 t/s`, `Generation 100.6 t/s`
- `100015` prompt tokens, `8` completion tokens: `Prompt 4365.5 t/s`, `Generation 84.4 t/s`

API local:

- `http://127.0.0.1:18083`

Observacoes:

- O `Gemma 4 E4B` sobe por padrao na sessao do usuario e, neste host, fica disponivel desde o boot via `systemd --user` com `linger` habilitado para `fmazzuco`.
- O preset usa `Q8_0` para manter qualidade alta sem pressionar a VRAM como o `f16` completo faria nesta GPU.
- O KV cache fica em `f16/f16`, que foi o ponto estavel validado aqui.
- Para o `ambient-assistant`, o preset padrao agora e `provider_kind=openai-compat` apontando para `http://127.0.0.1:18083/v1` com perfil `thinking-general`.
