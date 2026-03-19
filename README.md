# NixOS

Repositorio declarativo da workstation NixOS `nixos`.

Este repo e a fonte de verdade para configuracao de sistema. Os dotfiles continuam em um repo separado e cuidam apenas do ambiente de usuario.

## Estrutura

- `flake.nix`: entrada principal do sistema.
- `hosts/nixos/`: definicao do host atual.
- `modules/common/`: base do sistema, desktop e pacotes.
- `modules/services/`: servicos e ajustes ligados ao hardware da maquina.
- `modules/ai/`: stack local do Qwen 3.5 35B A3B via `llama.cpp`.
- `modules/compat/`: compatibilidade entre sistema e configuracoes de usuario.
- `docs/`: notas operacionais do host.
- `bin/`: atalhos para validar e aplicar a configuracao.

## Como usar

Validar a configuracao sem trocar o boot default:

```bash
cd ~/repos/nixos
./bin/test
```

Aplicar a configuracao:

```bash
cd ~/repos/nixos
./bin/switch
```

Tambem funciona sem entrar no repo:

```bash
sudo nixos-rebuild test --flake ~/repos/nixos#nixos
sudo nixos-rebuild switch --flake ~/repos/nixos#nixos
```

## Notas do host

- O repo assume o hostname `nixos`.
- O driver Wi-Fi depende de arquivos locais em `/home/fmazzuco/mt7902-driver`.
- O modelo GGUF do Qwen continua fora do repo em `/home/fmazzuco/models/qwen/Qwen3.5-35B-A3B-GGUF`.
- O provider do `opencode` continua no repo de dotfiles.

## Fluxo recomendado

1. Editar este repo.
2. Rodar `./bin/check` e `./bin/test`.
3. Aplicar com `./bin/switch` quando a mudanca precisar ficar persistente.
