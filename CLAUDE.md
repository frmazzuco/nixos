# CLAUDE.md

Read [AGENTS.md](AGENTS.md) for missao, mapa rapido, guardrails, e regras de entrega.

## Quick reference

- Validar: `./bin/harness`
- Testar: `./bin/test`
- Aplicar: `./bin/switch`
- Checar flake: `./bin/check`

## Ambient assistant integration points

- `modules/services/ambient-assistant.nix` — systemd user service for the assistant backend
- `modules/ai/gemma4-26b.nix` — Gemma 4 26B model server (base URL `http://127.0.0.1:18083/v1`)
- The assistant service depends on `gemma4-26b-server.service` (After=)

## Related repos

- `~/repos/ambient-assistant` — backend service source code
- `~/repos/dotfiles` — shell hooks, widget UI, keybindings
