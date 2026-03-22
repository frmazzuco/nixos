# Host Map

Mapa curto do host `nixos` e dos limites deste repositorio.

## Entradas

- `flake.nix` expoe `nixosConfigurations.nixos`
- `hosts/nixos/default.nix` compoe o host importando modulos por area

## Modulos

- `modules/ai/common.nix`: base compartilhada para `llama.cpp`, downloads de modelos e serviços locais
- `modules/common/base.nix`: boot, locale, usuario, Docker, fontes, shell e base do sistema
- `modules/common/desktop.nix`: X11, greetd/tuigreet, Hyprland, GPU hibrida, XRDP, audio, Tailscale e portals
- `modules/common/packages.nix`: ferramentas globais e pacotes do dia a dia
- `modules/common/quickshell-core.nix`: runtime e dependencias do Quickshell
- `modules/ai/qwen35-a3b.nix`: preset 35B A3B, wrappers e servico opcional
- `modules/ai/qwen35-9b.nix`: preset 9B, wrappers e servico padrao da sessao do usuario
- `modules/ai/qwen35-27b-unsloth.nix`: preset 27B, wrappers e servico opcional
- `modules/compat/user-dotfiles.nix`: compatibilidade entre sistema e ambiente de usuario
- `modules/services/openrgb-kingston.nix`: ajuste de RGB da memoria no boot

## Limites

- Este repo define comportamento de sistema e servicos locais da maquina.
- O repo de dotfiles continua responsavel por shell, Neovim, OpenCode e configuracao de usuario.
- Os presets de IA compartilham uma base comum em `modules/ai/common.nix`; diferenças de perfil continuam locais a cada preset.
- Modelos GGUF, credenciais, caches e outros artefatos locais continuam fora do versionamento.
