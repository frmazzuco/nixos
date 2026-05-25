# Backups

Backups locais da workstation `nixos` usam `restic` com repositorio criptografado em `/mnt/orico-storage/Backups/workstation-restic`.

O volume ORICO e RAID0. Ele e um destino local conveniente, mas nao substitui uma copia externa ou remota.

## Escopo

Incluido no job `workstation-local`:

- `/home/fmazzuco/repos`
- `/home/fmazzuco/arr/config`
- `/home/fmazzuco/arr/security`
- `/home/fmazzuco/jellyfin/config`
- `/home/fmazzuco/.ssh`
- `/home/fmazzuco/.secrets`
- `/home/fmazzuco/.config/cloudflared`
- `/home/fmazzuco/.config/sunshine`

Excluido por padrao: caches de projeto, `node_modules`, `.direnv`, `.pytest_cache`, symlinks `result` e logs de apps em `arr`/`jellyfin`.

O job nao faz dumps app-native de bancos. Para Rocket.Chat, PostgreSQL, Redis ou MinIO, gere dumps antes quando precisar de restore consistente de aplicacao.

## Segredo local

A senha canonica fica no Bitwarden CLI, no item `linux`. O restic/systemd le uma copia local materializada fora do Git em:

```bash
/home/fmazzuco/.config/restic/workstation-local-password
```

Depois de desbloquear o vault, sincronize a copia local:

```bash
export BW_SESSION="$(bw unlock --raw)"
restic-workstation-local-sync-password
```

O wrapper usa `bw get password linux` por padrao. Para outro item, rode `BITWARDEN_ITEM=nome-do-item restic-workstation-local-sync-password`. O arquivo local deve ficar com permissao `0600`.

## Operacao

Depois de aplicar a configuracao e sincronizar a senha via Bitwarden CLI:

```bash
sudo systemctl status restic-backups-workstation-local.timer
sudo systemctl start restic-backups-workstation-local.service
sudo restic-workstation-local snapshots
```

O timer roda diariamente por volta de `03:30`, com atraso aleatorio de ate `45min`, e mantem 7 diarios, 4 semanais e 6 mensais.

## Restore smoke

Depois do primeiro backup, valide um restore pequeno:

```bash
sudo rm -rf /tmp/restic-restore-smoke
sudo mkdir -p /tmp/restic-restore-smoke
sudo restic-workstation-local restore latest \
  --target /tmp/restic-restore-smoke \
  --include /home/fmazzuco/repos/nixos/README.md
sudo test -f /tmp/restic-restore-smoke/home/fmazzuco/repos/nixos/README.md
```

## Restore real

Liste snapshots:

```bash
sudo restic-workstation-local snapshots
```

Restaure para um diretorio temporario antes de sobrescrever dados vivos:

```bash
sudo restic-workstation-local restore <snapshot-id> --target /tmp/restore-workstation
```
