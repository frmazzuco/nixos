# NixOS

Configuracao declarativa da workstation `nixos`, baseada em flake e separada dos dotfiles de usuario.

Este repo concentra o que realmente muda o comportamento da maquina: boot, desktop, GPU hibrida, rede, servicos, pacotes globais e stack local de IA. Shell, Neovim, OpenCode e outras preferencias de usuario continuam no repo de dotfiles.

## O que tem aqui

- Host `nixos` pronto para `nixos-rebuild --flake`.
- Base pinada em `nixos-25.11`.
- Overlay pratico com `nixpkgs-unstable` para componentes mais volateis.
- Build custom do `llama.cpp` com CUDA arch `120`.
- Wrappers do Qwen 3.5 35B A3B para chat, server e download.
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
│   ├── compat/
│   └── services/
├── docs/
└── bin/
```

## Modulos

- `hosts/nixos/`: ponto de entrada do host atual.
- `modules/common/base.nix`: locale, boot, usuario, Docker, fontes e base do sistema.
- `modules/common/desktop.nix`: X11, GNOME, Hyprland, NVIDIA/AMD, XRDP, PipeWire e Tailscale.
- `modules/common/packages.nix`: pacotes globais e ferramentas do dia a dia.
- `modules/services/mt7902-driver.nix`: carga do driver Wi-Fi custom e ajuste do NetworkManager.
- `modules/ai/qwen35-a3b.nix`: `llama.cpp` com CUDA + wrappers `qwen35-a3b-*`.
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

## Dependencias locais

Alguns itens continuam fora do repo por serem hardware-specific ou estado local:

- `/home/fmazzuco/mt7902-driver`: binarios e firmware do driver Wi-Fi.
- `/home/fmazzuco/models/qwen/Qwen3.5-35B-A3B-GGUF`: modelos GGUF.
- Segredos, tokens, caches e credenciais.

## Relacao com os dotfiles

Separacao adotada:

- Este repo: sistema operacional e comportamento da maquina.
- Repo de dotfiles: configuracoes de usuario e apps, como `zsh`, `nvim` e `opencode`.

Na pratica, o provider do OpenCode que aponta para o Qwen local continua no repo de dotfiles, enquanto o servidor local e os binarios que o sustentam ficam aqui.

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
