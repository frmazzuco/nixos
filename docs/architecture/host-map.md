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
- `modules/common/desktop.nix`: X11, greetd/tuigreet, Hyprland, GPU hibrida, XRDP, audio, Tailscale e portals
- `modules/common/packages.nix`: ferramentas globais, pacotes do dia a dia, `agsFull` do upstream e `stow` para a camada ativa de dotfiles
- `modules/common/quickshell-core.nix`: runtime e dependencias do Quickshell
- `modules/ai/qwen35-a3b.nix`: preset 35B A3B, wrappers e servico opcional
- `modules/ai/qwen35-9b.nix`: preset 9B, wrappers e servico padrao da sessao do usuario
- `modules/ai/qwen35-27b-unsloth.nix`: preset 27B, wrappers e servico opcional
- `modules/compat/default.nix`: entrypoint da compatibilidade com o ambiente do usuario
- `modules/compat/user-dotfiles.nix`: compatibilidade entre sistema e ambiente de usuario
- `modules/services/default.nix`: entrypoint dos servicos locais transversais
- `modules/services/ambient-assistant.nix`: backend local usado pelo widget de IA
- `modules/services/orico-storage.nix`: suporte `mdadm` e montagem automatica do volume unico externo em `/mnt/orico-storage`
- `modules/services/sunshine.nix`: espelhamento da sessao atual do Hyprland via Moonlight, restrito ao Tailscale
- `modules/services/openrgb-kingston.nix`: ajuste de RGB da memoria no boot

## Limites

- Este repo define comportamento de sistema e servicos locais da maquina.
- O repo de dotfiles continua responsavel por shell, Neovim, OpenCode e configuracao de usuario.
- O runtime de notificacoes usa `ags` do sistema; a configuracao do app e o launcher da sessao continuam no repo de dotfiles.
- Os presets de IA compartilham uma base comum em `modules/ai/common.nix`; diferenças de perfil continuam locais a cada preset.
- `modules/ai/` segue como dono dos servicos especificos de preset; `modules/services/` concentra servicos locais transversais e dependentes desses presets.
- Caminhos-base do host e identidade do usuario ficam centralizados em `modules/common/host-context.nix`.
- Modelos GGUF, credenciais, caches e outros artefatos locais continuam fora do versionamento.
