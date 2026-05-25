# Host Map

Mapa curto do host `nixos` e dos limites deste repositorio.

## Entradas

- `flake.nix` expoe `nixosConfigurations.nixos`
- `hosts/nixos/default.nix` compoe o host importando entrypoints por area

## Modulos

- `modules/common/default.nix`: entrypoint da base do host
- `modules/ai/common.nix`: base compartilhada para `llama.cpp`, downloads de modelos e serviços locais
- `modules/ai/default.nix`: entrypoint dos presets de IA
- `modules/common/host-context.nix`: usuario principal e caminhos-base compartilhados do host
- `modules/common/base.nix`: boot, locale, usuario, Docker, fontes, shell e base do sistema
- `modules/common/maintenance.nix`: GC do Nix, otimizacao do store e limite do journald
- `modules/common/desktop.nix`: X11, greetd/tuigreet, Hyprland, GPU hibrida, Bluetooth/BlueZ, XRDP, audio, Tailscale e portals
- `modules/common/packages.nix`: ferramentas globais, pacotes do dia a dia, `agsFull` do upstream e `stow` para a camada ativa de dotfiles
- `modules/common/quickshell-core.nix`: runtime e dependencias do Quickshell
- `modules/ai/qwen35-9b.nix`: preset 9B, wrappers e servico manual
- `modules/ai/gemma4-e4b.nix`: preset Gemma 4 E4B e wrappers para uso manual
- `modules/ai/gemma4-26b.nix`: preset Gemma 4 26B, wrappers e servico padrao da sessao do usuario
- `modules/compat/default.nix`: entrypoint da compatibilidade com o ambiente do usuario
- `modules/compat/user-dotfiles.nix`: compatibilidade entre sistema e ambiente de usuario
- `modules/services/default.nix`: entrypoint dos servicos locais transversais
- `modules/services/ambient-assistant.nix`: backend local usado pelo widget de IA
- `modules/services/backups.nix`: backup local criptografado com restic para configs, repos e segredos selecionados, com senha vinda do item `linux` no Bitwarden CLI
- `modules/services/cloudflared-media-tunnel.nix`: tunel persistente de Jellyfin e Seerr via Cloudflare, resolvendo o token do tunel no BWS
- `modules/services/mt7902-driver.nix`: kernel compativel, regdom BR, NetworkManager sem powersave no Wi-Fi, firmware e carga dos modulos `mt76`/`mt7921e` e `btusb`/`btmtk` da placa Wi-Fi/Bluetooth MT7902
- `modules/services/orico-storage.nix`: suporte `mdadm` e montagem automatica do volume unico externo em `/mnt/orico-storage`
- `modules/services/sunshine.nix`: espelhamento da sessao atual do Hyprland via Moonlight, com NVENC e `Sunshine_Microphone`, restrito ao Tailscale
- `modules/services/openrgb-kingston.nix`: ajuste de RGB da memoria no boot

## Limites

- Este repo define comportamento de sistema e servicos locais da maquina.
- O repo de dotfiles continua responsavel por shell, Neovim, OpenCode e configuracao de usuario.
- O runtime de notificacoes usa `ags` do sistema; a configuracao do app e o launcher da sessao continuam no repo de dotfiles.
- Os presets de IA compartilham uma base comum em `modules/ai/common.nix`; diferenças de perfil continuam locais a cada preset.
- `modules/ai/` segue como dono dos servicos especificos de preset; `modules/services/` concentra servicos locais transversais e dependentes desses presets.
- Caminhos-base do host e identidade do usuario ficam centralizados em `modules/common/host-context.nix`.
- Modelos GGUF, credenciais, caches e outros artefatos locais continuam fora do versionamento.
- O tunel de Jellyfin e Seerr depende de um arquivo local `~/.config/cloudflared/media-bws.env` com o `BWS_ACCESS_TOKEN`; o token do Cloudflare continua vindo do BWS em runtime.
