# Harness

Comando canonico local:

```bash
./bin/harness
```

O harness atual roda apenas checks deterministicos e sem privilegios.

## Matriz

| Regra | Mecanismo | Comando | Evidencia |
| --- | --- | --- | --- |
| O flake precisa avaliar e expor o host `nixos` | check nativo do Nix | `./bin/check` | exit `0` |
| Literais do host nao devem voltar a se espalhar entre modulos | script shell pequeno | `tests/test_host_context_contract.sh` | usuario e caminhos-base ficam centralizados em `modules/common/host-context.nix` |
| O host deve continuar importando entrypoints por area | script shell pequeno | `tests/test_module_area_entrypoints.sh` | `hosts/nixos/default.nix` importa `modules/common`, `modules/ai`, `modules/compat` e `modules/services` |
| Presets de IA devem compartilhar a base estrutural comum | script shell pequeno | `tests/test_ai_module_structure.sh` | os presets importam `modules/ai/common.nix` e nao recompõem `llama.cpp` localmente |
| So um servico de IA sobe por padrao na sessao do usuario | script shell pequeno | `tests/test_ai_default_service.sh` | exactly one `wantedBy = [ "default.target" ];` entre os presets `modules/ai/qwen*.nix` |
| Docs dos presets precisam refletir defaults reais do codigo | script shell pequeno | `tests/test_ai_docs_sync.sh` | strings criticas de perfil, contexto, endpoint e autostart sincronizadas |
| O runner local deve continuar descobrindo contracts automaticamente | script shell pequeno | `tests/run-all.sh` | todo `tests/test_*.sh` e executado via o mesmo entrypoint |

## Ordem de uso

1. Rodar `./bin/harness` em toda mudanca normal.
2. Rodar `./bin/test` quando a mudanca exigir validacao de rebuild do sistema.
3. Rodar `./bin/switch` apenas quando fizer sentido aplicar a configuracao no host atual.

`./bin/harness` executa `./bin/check` e depois chama `tests/run-all.sh`, que descobre todos os `tests/test_*.sh` em ordem lexicografica.

## Backlog curto

- Promover `./bin/harness` para CI quando houver pipeline no repo.
- Se o contrato dos presets crescer, trocar comparacoes textuais por extracao estruturada dos defaults.
