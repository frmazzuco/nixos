# Qwen 3.8 27B

O módulo `modules/ai/qwen38-27b.nix` mantém o Qwen 3.8 27B como servidor local
padrão. Ele usa o GGUF `Qwen3.8-27B-UD-Q3_K_XL.gguf`, publicado no repositório
`unsloth/Qwen3.8-27B-GGUF`.

O serviço atende somente em `http://127.0.0.1:8082`. A exposição na Tailnet é
feita separadamente pelo Tailscale Serve; não há porta aberta na rede local.

## Ajustes padrão

- `ctx-size=102400`;
- lote `1024` e microlote `256`;
- `cache-type-k=q4_0` e `cache-type-v=q4_0`;
- todas as camadas principais na GPU;
- MTP desativado neste perfil para não exceder os 16 GB de VRAM;
- perfil `thinking-general`;
- uma requisição paralela.

O ensaio na RTX 5070 Ti consumiu cerca de 14,8 GB de VRAM com contexto de
102.400 tokens e manteve aproximadamente 50 tokens por segundo na geração.

## Operação

```bash
systemctl --user status qwen38-27b-server
curl -fsS http://127.0.0.1:8082/health
```

O serviço `qwen38-27b-server` entra em conflito com `qwen35-9b-server`, pois os
dois compartilham a porta 8082. O 9B continua instalado para reversão manual.

Para baixar novamente o modelo:

```bash
qwen38-27b-download
```
