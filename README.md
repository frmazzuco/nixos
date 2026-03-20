# NixOS

Configuracao declarativa da workstation `nixos`, baseada em flake e separada dos dotfiles de usuario.

Este repo concentra o que realmente muda o comportamento da maquina: boot, desktop, GPU hibrida, rede, servicos, pacotes globais e stack local de IA. Shell, Neovim, OpenCode e outras preferencias de usuario continuam no repo de dotfiles.

## O que tem aqui

- Host `nixos` pronto para `nixos-rebuild --flake`.
- Base pinada em `nixos-25.11`.
- Overlay pratico com `nixpkgs-unstable` para componentes mais volateis.
- Build custom do `llama.cpp` com CUDA arch `120`.
- Wrappers do Qwen 3.5 35B A3B para chat, server e download.
- Wrappers do Qwen 3.5 9B para chat, server e download, com preset separado para baixa latencia.
- Servico `systemd --user` para manter o server do Qwen disponivel para o OpenCode.
- Thinking desativado no server local do Qwen para evitar loops longos no OpenCode.
- Compatibilidade local para `bubblewrap` e plugins do shell.
- Modulos separados por area, sem enfiar tudo em um `configuration.nix` gigante.

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
- `modules/common/base.nix`: locale, boot, usuario, Docker, fontes e base do sistema.
- `modules/common/desktop.nix`: X11, GNOME, Hyprland, NVIDIA/AMD, XRDP, PipeWire e Tailscale.
- `modules/common/packages.nix`: pacotes globais e ferramentas do dia a dia.
- `modules/ai/qwen35-a3b.nix`: `llama.cpp` com CUDA, wrappers `qwen35-a3b-*` e servico local para o OpenCode.
- `modules/ai/qwen35-9b.nix`: wrappers `qwen35-9b-*` para um preset paralelo do Qwen focado em velocidade.
- `modules/compat/user-dotfiles.nix`: compatibilidade entre sistema e ambiente de usuario.

## Uso rapido

Checar o flake:

```bash
cd ~/repos/nixos
./bin/check
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

Gerenciar o server do Qwen no usuario:

```bash
systemctl --user status qwen35-a3b-server
systemctl --user restart qwen35-a3b-server
systemctl --user start qwen35-9b-server
systemctl --user stop qwen35-9b-server
journalctl --user -u qwen35-a3b-server -f
```

Os dois presets podem coexistir no host, mas nao devem ficar ativos ao mesmo tempo na GPU. Os servicos `qwen35-a3b-server` e `qwen35-9b-server` foram declarados com `Conflicts=` para evitar disputa de VRAM.

## Dependencias locais

Alguns itens continuam fora do repo por serem hardware-specific ou estado local:

- `/home/fmazzuco/models/qwen/Qwen3.5-35B-A3B-GGUF`: modelos GGUF.
- `/home/fmazzuco/models/qwen/Qwen3.5-9B-GGUF`: modelos GGUF.
- Segredos, tokens, caches e credenciais.

## Relacao com os dotfiles

Separacao adotada:

- Este repo: sistema operacional e comportamento da maquina.
- Repo de dotfiles: configuracoes de usuario e apps, como `zsh`, `nvim` e `opencode`.

Na pratica, o provider do OpenCode que aponta para o Qwen local continua no repo de dotfiles, enquanto o servidor local, os binarios e o servico `systemd --user` que o sustenta ficam aqui.

## Fluxo recomendado

1. Editar o modulo certo.
2. Rodar `./bin/check`.
3. Rodar `./bin/test`.
4. Aplicar com `./bin/switch` quando fizer sentido.

## Notas do host atual

- Hostname esperado: `nixos`.
- `system.stateVersion`: `25.11`.
- O repo foi pensado para a configuracao real desta workstation, nao como template generico.
- A documentacao do preset local do Qwen esta em `docs/qwen35-a3b.md`.
- A documentacao do preset rapido do Qwen esta em `docs/qwen35-9b.md`.
