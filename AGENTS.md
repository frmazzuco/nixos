# AGENTS

## Missao

Manter esta configuracao NixOS como fonte de verdade operacional da workstation `nixos`, com mudancas pequenas, verificaveis e documentadas no proprio repositorio.

## Mapa Rapido

- `flake.nix`: entrada do flake e exposicao de `nixosConfigurations.nixos`
- `hosts/nixos/default.nix`: composicao do host atual
- `modules/common/*.nix`: base do sistema, desktop, pacotes e runtime do Quickshell
- `modules/ai/*.nix`: wrappers, presets e servicos locais de IA
- `modules/compat/*.nix`: compatibilidade entre sistema e ambiente de usuario
- `modules/services/*.nix`: servicos pontuais do host
- `bin/check`: `nix flake check`
- `bin/harness`: validacao local sem privilegios
- `bin/test`: `sudo nixos-rebuild test`
- `bin/switch`: `sudo nixos-rebuild switch`

## Guardrails

- Toda mudanca de comportamento, default, porta, perfil, comando operacional ou fluxo de uso deve atualizar a documentacao na mesma entrega.
- Toda mudanca deve adicionar ou ajustar checks/testes deterministicos quando houver regra objetiva para proteger.
- Antes de encerrar uma tarefa, rode `./bin/harness` e os comandos adicionais da area alterada. Se nao puder rodar algo, registre o motivo.
- Mantenha `AGENTS.md` curto. Conhecimento estavel e detalhado deve ir para `docs/`.
- Nao duplique contexto sem necessidade. Prefira um documento fonte e links claros.
- Nao editar `hosts/nixos/hardware-configuration.nix` sem motivo explicito ligado a hardware.
- Nao introduzir segredos, tokens ou estado local no repo. Quando algo externo for necessario, documente como dependencia local.

## Regras de Entrega

- Se mexer em `modules/ai/*.nix`, atualize as docs dos presets e rode `tests/test_ai_default_service.sh` e `tests/test_ai_docs_sync.sh` via `./bin/harness`.
- Se mexer em comandos operacionais, atualize `README.md` e `docs/operations/harness.md` quando aplicavel.
- Se criar uma nova regra importante e deterministica, prefira colocá-la em um check pequeno antes de deixá-la apenas em texto.

## Ponteiros

- Arquitetura do host: `docs/architecture/host-map.md`
- Harness de qualidade: `docs/operations/harness.md`
- Inventario resumido: `docs/generated/repo-inventory.md`
