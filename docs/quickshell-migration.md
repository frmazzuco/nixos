# Migracao do Quickshell para o Host `nixos`

Plano consolidado da migracao do setup de Quickshell para o ambiente do host `nixos`, com separacao entre runtime do sistema e configuracao de usuario.

## Objetivo

Levar o Quickshell para o ambiente atual de forma incremental, mantendo o host operavel em cada passo e sem introduzir Home Manager na workstation.

Separacao adotada:

- `repos/nixos`: runtime, pacotes e servicos do sistema
- `repos/dotfiles`: QML, scripts, binds e configuracao do Hyprland

## Arquitetura alvo

### Runtime no `repos/nixos`

- `modules/common/quickshell-core.nix`
  - `quickshell`
  - `qt6.qtmultimedia`
  - `qt6.qt5compat`
  - `brightnessctl`
  - `socat`
  - `cliphist`
  - `swww`
  - `ffmpeg`
  - `imagemagick`
  - `libnotify`
  - `curl`
  - `bc`

### Config de usuario no `repos/dotfiles`

- `hypr/.config/hypr/scripts/quickshell/`
  - `Main.qml`
  - `TopBar.qml`
  - `battery/`
  - `music/`
  - `network/`
  - `calendar/`
  - `sys_info.sh`
  - `workspaces.sh`
- `hypr/.config/hypr/scripts/qs_manager.sh`
- `hypr/.config/hypr/scripts/quickshell-start.sh`
- `hypr/.config/hypr/scripts/launch-terminal.sh`

## Estado atual

### Concluido

- Runtime do Quickshell declarado no flake do `repos/nixos`
- Core do Quickshell portado para o `repos/dotfiles`
- Integracao incremental no `hyprland.conf`
- Fallback para `waybar` antes do runtime existir
- `qs_manager.sh` adaptado para o ambiente local
- `Main.qml` ajustado para tamanho de tela dinamico
- `sys_info.sh` ajustado para layout `BR`
- `calendar` desacoplado do ambiente do autor com fallbacks seguros
- `equalizer.sh` tolerando ausencia de `easyeffects`
- Top bar corrigida para workspaces `1..10`
- Estado de workspaces corrigido para nao crescer indefinidamente em `/tmp`
- `ghostty` no Hyprland endurecido com launcher sem reuse de instancia
- Runtime aplicado no host com `nixos-rebuild test` e `switch`

### Aplicado na sessao

- `quickshell` instalado no sistema
- `qwen35-9b-server` promovido a preset padrao em `127.0.0.1:8080`
- `Main.qml` e `TopBar.qml` ativos na sessao
- `waybar` removido da sessao atual
- modulo `wallpaper` portado com bind `Super+W`
- diretório padrao de wallpapers definido em `~/Wallpapers`
- picker tolerando pasta vazia e ambiente sem `mpvpaper`
- modulo `monitors` portado com bind `Super+Shift+M`
- modulo `focustime` portado com bind `Super+Shift+T`
- modulo `stewart` portado com bind `Super+Shift+S`

## Pendencias

### Integracoes opcionais

- `easyeffects`
- `mpvpaper`
- `swaync`
- `swayosd`
- weather real com credenciais locais
- agenda real com fonte de dados do usuario
- diario do Obsidian com paths locais definitivos

### Estabilizacao

- validar binds em login frio no Hyprland
- validar popup de bateria com ajuste de brilho
- validar popup de rede com `nmcli` e `bluetoothctl`
- validar top bar apos reboot/login
- revisar visual e posicionamento dos popups

## Proximos passos sugeridos

1. Fechar a estabilizacao do core no login frio do Hyprland.
2. Escolher qual extra entra primeiro: `wallpaper`, `monitors` ou `focustime`.
3. Registrar commits separados para `repos/nixos` e `repos/dotfiles`.
