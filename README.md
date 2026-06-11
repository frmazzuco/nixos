# NixOS

Configuracao declarativa da workstation `nixos`, baseada em flake e separada dos dotfiles de usuario.

Este repo concentra o que realmente muda o comportamento da maquina: boot, desktop, GPU hibrida, rede, servicos, pacotes globais e stack local de IA. Shell, Neovim, OpenCode e outras preferencias de usuario continuam no repo de dotfiles.

## O que tem aqui

- Host `nixos` pronto para `nixos-rebuild --flake`.
- Base pinada em `nixpkgs-unstable`.
- Alias `nixpkgs-unstable` mantido para componentes que ainda referenciam esse input nominalmente.
- Input `mt7902-temp` para compilar os modulos `mt76`/`mt7921e` e o patch local `btusb`/`btmtk` com suporte a placa Wi-Fi/Bluetooth MT7902.
- Input dedicado do upstream `github:aylur/ags` para o runtime de notificacoes do desktop.
- Build custom do `llama.cpp` com CUDA arch `120`.
- Toolchain CUDA basico disponivel globalmente no host via `cudaPackages.cuda_nvcc` e `cudaPackages.cuda_cudart`.
- Wrappers do Qwen 3.5 9B para chat, server e download, mantidos para uso manual local.
- `claude-code` disponivel globalmente no host via binario oficial pinado.
- Presets locais de IA instalados para uso manual, sem `llama-server` subindo por padrao.
- Servico `systemd --user` para manter o `ambient-assistant` disponivel para o widget local de IA.
- Harness local sem privilegios para validar flake, defaults e sincronismo basico entre codigo e docs.
- Compatibilidade local para `bubblewrap` e plugins do shell.
- Modulos separados por area, sem enfiar tudo em um `configuration.nix` gigante.
- Manutencao automatica do host: GC do Nix, otimizacao do store e limite do journald.
- Backup local criptografado com restic para repos, configs e segredos selecionados.
- Contexto do host centralizado em `modules/common/host-context.nix`, evitando espalhar usuario e caminhos-base em varios modulos.
- O host importa entrypoints por area (`modules/common`, `modules/ai`, `modules/compat`, `modules/services`) em vez de listar arquivos soltos.

## Layout

```text
.
├── flake.nix
├── hosts/
│   └── nixos/
├── modules/
│   ├── ai/
│   ├── common/
│   └── compat/
├── docs/
└── bin/
```

## Modulos

- `hosts/nixos/`: ponto de entrada do host atual.
- `modules/common/default.nix`: entrypoint da camada base do host.
- `modules/common/base.nix`: locale, boot, usuario, Docker, fontes e base do sistema.
- `modules/common/maintenance.nix`: GC do Nix, otimizacao do store e retencao do journald.
- `modules/common/host-context.nix`: usuario principal e caminhos-base compartilhados pelos modulos do host.
- `modules/common/desktop.nix`: X11, greetd/tuigreet, Hyprland, Steam, NVIDIA/AMD, Bluetooth/BlueZ, XRDP, PipeWire e Tailscale.
- `modules/common/packages.nix`: pacotes globais, ferramentas do dia a dia, runtime/toolchain CUDA, Discord, `agsFull` do upstream e `stow` para aplicar a configuracao ativa do desktop.
- `modules/common/quickshell-core.nix`: runtime do Quickshell e dependencias da barra/widgets.
- `modules/ai/default.nix`: entrypoint dos presets e wrappers locais de IA.
- `modules/ai/common.nix`: helper compartilhado para `llama.cpp`, downloads e serviços locais de IA.
- `modules/ai/qwen35-9b.nix`: wrappers `qwen35-9b-*` e servico local manual para o OpenCode.
- `modules/ai/gemma4-e4b.nix`: wrappers `gemma4-e4b-*` e preset manual para o Gemma 4 E4B.
- `modules/ai/gemma4-26b.nix`: wrappers `gemma4-26b-*` e servico local padrao para o Gemma 4 26B.
- `modules/compat/default.nix`: entrypoint da camada de compatibilidade com o ambiente do usuario.
- `modules/compat/user-dotfiles.nix`: compatibilidade entre sistema e ambiente de usuario.
- `modules/services/default.nix`: entrypoint dos servicos locais da workstation.
- `modules/services/ambient-assistant.nix`: servico `systemd --user` do backend local usado pelo widget de IA.
- `modules/services/backups.nix`: backup local criptografado via restic para configs, repos e segredos selecionados, com senha materializada a partir do item `linux` no Bitwarden CLI.
- `modules/services/cloudflared-media-tunnel.nix`: tunel persistente de Jellyfin e Seerr via Cloudflare, buscando o token do tunel no BWS em runtime.
- `modules/services/mt7902-driver.nix`: kernel compativel, regdom BR, NetworkManager sem powersave no Wi-Fi, firmware e carga dos modulos `mt76`/`mt7921e` e `btusb`/`btmtk` da placa Wi-Fi/Bluetooth MT7902.
- `modules/services/orico-storage.nix`: suporte `mdadm` e montagem automatica do volume unico externo em `/mnt/orico-storage`.
- `modules/services/sunshine.nix`: espelhamento remoto da sessao atual do `Hyprland` via `Moonlight`, com NVENC e `Sunshine_Microphone`, restrito a `tailscale0`.
- `modules/services/openrgb-kingston.nix`: ajuste de RGB da memoria no boot.

## Uso rapido

Checar o flake:

```bash
cd ~/repos/nixos
./bin/check
```

Rodar o harness local:

```bash
cd ~/repos/nixos
./bin/harness
```

Validar sem trocar o boot default:

```bash
cd ~/repos/nixos
./bin/test
```

Aplicar de forma persistente:

```bash
cd ~/repos/nixos
./bin/switch
```

Tambem funciona direto:

```bash
sudo nixos-rebuild test --flake ~/repos/nixos#nixos
sudo nixos-rebuild switch --flake ~/repos/nixos#nixos
```

Os wrappers `./bin/check`, `./bin/test` e `./bin/switch` usam a mesma resolucao `git+file` desses comandos diretos. Se voce criar arquivo novo no repo, faca `git add` antes do rebuild para a validacao enxergar o mesmo conjunto de arquivos.

Gerenciar o server do Qwen no usuario:

```bash
systemctl --user status qwen35-9b-server
systemctl --user restart qwen35-9b-server
systemctl --user stop qwen35-9b-server
journalctl --user -u qwen35-9b-server -f
```

Nenhum preset de IA sobe por padrao desde o boot; inicie `gemma4-26b-server`, `gemma4-e4b-server` ou `qwen35-9b-server` manualmente quando precisar do endpoint local.
O `ambient-assistant` sobe por `default.target`, usando `openai-compat` apontando para `http://127.0.0.1:18083/v1` com `gemma-4-26B-A4B-it-UD-IQ4_XS.gguf` e perfil `thinking-general`, mas nao inicia o `llama-server` sozinho. O modulo monta um Python dedicado com `openai-agents`, mantendo o checkout do repo em `PYTHONPATH`.
Para a tool local do Seerr, o servico tambem recebe `AMBIENT_ASSISTANT_SEERR_SETTINGS_FILE=%h/arr/config/jellyseerr/settings.json` e le a `main.apiKey` diretamente desse arquivo, sem depender de um wrapper extra no startup.
O tunel persistente de Jellyfin e Seerr sobe por `systemd --user` como `cloudflared-media-tunnel`, usando `cloudflared tunnel --token` e buscando o token do Cloudflare no BWS em runtime. O bootstrap local depende do arquivo `~/.config/cloudflared/media-bws.env` com `BWS_ACCESS_TOKEN` e, opcionalmente, `CLOUDFLARE_TUNNEL_BWS_SECRET_KEY` (default `cloudflare`) ou `CLOUDFLARE_TUNNEL_BWS_SECRET_ID`.
Os servicos especificos de cada preset continuam em `modules/ai/*.nix`; servicos locais transversais, como `ambient-assistant`, `sunshine` e `openrgb`, ficam agregados em `modules/services/`.
O storage externo ORICO usa um volume unico `RAID0` montado em `/mnt/orico-storage` quando o gabinete estiver conectado; a montagem foi declarada com `nofail` e `x-systemd.automount` para nao atrasar o boot se ele estiver desligado.
O Bluetooth do desktop usa BlueZ com `powerOnBoot`, `blueman` e `upower`, deixando `bluetooth.service`, `bluetoothctl`, `upowerd` e `upower` disponiveis apos aplicar a configuracao. O `upower` cobre consultas de bateria de perifericos que exponham esse dado ao sistema.

## Dependencias locais

Alguns itens continuam fora do repo por serem hardware-specific ou estado local:

- `/home/fmazzuco/models/qwen/Qwen3.5-9B-GGUF`: modelos GGUF.
- `/home/fmazzuco/models/gemma4/gemma-4-E4B-it-GGUF`: modelos GGUF.
- `/home/fmazzuco/models/gemma4/gemma-4-26B-A4B-it-GGUF`: modelos GGUF.
- `/home/fmazzuco/.config/cloudflared/media-bws.env`: `BWS_ACCESS_TOKEN` local para o servico `cloudflared-media-tunnel`.
- Segredos, tokens, caches e credenciais.

## Relacao com os dotfiles

Separacao adotada:

- Este repo: sistema operacional e comportamento da maquina.
- Repo de dotfiles: configuracoes de usuario e apps, como `zsh`, `nvim` e `opencode`.

Na pratica, o provider do OpenCode que aponta para o Qwen local continua no repo de dotfiles, enquanto os servidores locais, os binarios e os servicos `systemd --user` que os sustentam ficam aqui.
O runtime de notificacoes usa `ags` do sistema; a configuracao e o launcher da sessao Hyprland ficam no repo de dotfiles.

## Fluxo recomendado

1. Editar o modulo certo.
2. Rodar `./bin/harness`.
3. Rodar `./bin/test`.
4. Aplicar com `./bin/switch` quando fizer sentido.

## Notas do host atual

- Hostname esperado: `nixos`.
- `system.stateVersion`: `25.11`.
- O repo foi pensado para a configuracao real desta workstation, nao como template generico.
- As regras operacionais para agentes e contribuidores estao em `AGENTS.md`.
- O mapa curto do host esta em `docs/architecture/host-map.md`.
- O harness de qualidade esta em `docs/operations/harness.md`.
- O fluxo operacional de acesso remoto fica em `docs/operations/remote-desktop.md`.
- O fluxo operacional de backup e restore fica em `docs/operations/backups.md`.
- A documentacao do preset rapido do Qwen esta em `docs/qwen35-9b.md`.
- A documentacao do preset local do Gemma 4 E4B esta em `docs/gemma4-e4b.md`.
- A documentacao do preset local do Gemma 4 26B esta em `docs/gemma4-26b.md`.
- O estado da migracao do desktop para Quickshell esta em `docs/quickshell-migration.md`.
