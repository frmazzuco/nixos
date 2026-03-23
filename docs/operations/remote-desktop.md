# Remote Desktop

Esta workstation expõe dois fluxos remotos diferentes:

- `XRDP` em `3389` via `tailscale0` para abrir uma sessao `XFCE` separada.
- `Sunshine` via `tailscale0` para espelhar a sessao atual do `Hyprland` em clientes `Moonlight`.

O `Sunshine` usa as portas padrao de stream no `tailscale0`, mas a Web UI fica local ao host em `https://localhost:47990`.

## Fluxo recomendado

1. No host `nixos`, confirmar que a sessao grafica do usuario esta ativa e abrir `https://localhost:47990`.
2. Criar as credenciais iniciais do Sunshine na Web UI local.
3. No cliente remoto, entrar na mesma tailnet e adicionar o host manualmente usando o IP do Tailscale do host.
4. Conferir o servico no host:

```bash
systemctl --user status sunshine
```

5. No cliente, usar `Moonlight` para parear e depois abrir `Desktop`.
6. Quando o `Moonlight` pedir o PIN, aprovar o pareamento na Web UI local do Sunshine.

## Notas

- Este fluxo espelha a sessao atual do `Hyprland`; nao cria uma sessao separada.
- O setup atual assume monitor fisico conectado.
- A Web UI nao e publicada na tailnet; o host precisa ser adicionado manualmente no `Moonlight`.
- Depois que a conexao abre, teclado e mouse sao enviados automaticamente pelo `Moonlight`.
- O `XRDP` continua disponivel como fallback para sessao separada.
