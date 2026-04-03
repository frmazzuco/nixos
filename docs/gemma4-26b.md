# Gemma 4 26B via llama.cpp

Preset local do `Gemma 4 26B A4B` validado nesta RTX 5070 Ti 16 GB.

Modelo padrao:

- Repo GGUF: `unsloth/gemma-4-26B-A4B-it-GGUF`
- Quantizacao: `gemma-4-26B-A4B-it-UD-IQ4_XS.gguf`
- Caminho local: `/home/fmazzuco/models/gemma4/gemma-4-26B-A4B-it-GGUF/gemma-4-26B-A4B-it-UD-IQ4_XS.gguf`

Comandos:

- `gemma4-26b-download`
- `gemma4-26b-chat`
- `gemma4-26b-server`
- `systemctl --user status gemma4-26b-server`
- `systemctl --user start gemma4-26b-server`
- `systemctl --user stop gemma4-26b-server`

Preset aplicado para esta RTX 5070 Ti 16 GB:

- `ctx-size=68000`
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

- `~64k` tokens reais: `Prompt 3284.8 t/s`, `Generation 106.7 t/s`
- `68k` passou com folga residual minima na VRAM (`~53 MiB` livres no smoke test)

API local:

- `http://127.0.0.1:18083`

Observacoes:

- O `Gemma 4 26B` agora fica como preset manual quando voce quiser priorizar mais qualidade em troca de uso maior de VRAM.
- O preset usa `flash-attn on` com `cache-type-k=f16` e `cache-type-v=f16`, que foi o melhor ponto medido aqui entre throughput e estabilidade.
- O `ctx-size=68000` funciona, mas fica bem perto do limite da VRAM; se voce quiser margem extra para variacao de carga, reduza para `64000`.
- Para testar com o `ambient-assistant`, prefira o preset `Gemma 4 E4B`; o `26B` pode ser subido manualmente na mesma porta quando voce quiser comparar qualidade.
