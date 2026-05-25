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

- `ctx-size=128000`
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
- `70k`, `80k`, `100k` e `128k` subiram nesta RTX 5070 Ti 16 GB com o preset atual quando testados com a GPU limpa

API local:

- `http://127.0.0.1:18083`

Observacoes:

- O `Gemma 4 26B` nao sobe por padrao na sessao do usuario; inicie `systemctl --user start gemma4-26b-server` quando precisar do endpoint local.
- O preset usa `flash-attn on` com `cache-type-k=f16` e `cache-type-v=f16`, que foi o melhor ponto medido aqui entre throughput e estabilidade.
- O `ctx-size=128000` esta validado neste host, mas deixa pouca folga de VRAM; se voce quiser mais margem para concorrencia ou carga grafica, reduza para `100000`.
- O `ambient-assistant` aponta para o endpoint do `Gemma 4 26B` na porta `18083`, mas nao inicia o `llama-server` sozinho; o widget local de IA so responde quando o servidor for iniciado manualmente.
