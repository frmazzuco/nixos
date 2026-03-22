# CLAUDE.md

Read [AGENTS.md](AGENTS.md) for missao, mapa rapido, guardrails, e regras de entrega.

## Quick reference

- Validar: `./bin/harness`
- Testar: `./bin/test`
- Aplicar: `./bin/switch`
- Checar flake: `./bin/check`

## Ambient assistant integration points

- `modules/services/ambient-assistant.nix` — systemd user service for the assistant backend
- `modules/ai/qwen35-9b.nix` — Qwen 3.5 9B model server (port 8080, thinking-general default)
- The assistant service depends on `qwen35-9b-server.service` (After=)

## Related repos

- `~/repos/ambient-assistant` — backend service source code
- `~/repos/dotfiles` — shell hooks, widget UI, keybindings
