# Migracao do Quickshell para o Host `nixos`

Estado consolidado da migracao do desktop para Quickshell, separando runtime de sistema e configuracao de usuario.

## Separacao adotada

- `repos/nixos`: pacotes e runtime do desktop
- `repos/dotfiles`: QML, scripts, binds e configuracao do Hyprland

## Estado atual

### Sistema

- `modules/common/quickshell-core.nix` concentra o runtime do Quickshell
- o modulo esta importado pelo host `nixos`
- o runtime inclui `quickshell`, `qt6.qtmultimedia`, `qt6.qt5compat`, `brightnessctl`, `socat`, `cliphist`, `swww`, `ffmpeg`, `imagemagick`, `libnotify`, `curl` e `bc`

### Usuario

- o Hyprland sobe Quickshell diretamente via `quickshell-start.sh`
- `Main.qml` e `TopBar.qml` sao os pontos de entrada da UI
- `qs_manager.sh` concentra toggles, bootstrap e integracao com o Hyprland
- `launch-terminal.sh` encapsula o launcher do terminal para evitar problemas com instancia unica do `ghostty`

### Widgets portados

- `battery`
- `calendar`
- `music`
- `network`
- `wallpaper`
- `monitors`
- `focustime`
- `stewart`

## Convencoes da base

- estado efemero fica em `${XDG_RUNTIME_DIR}/quickshell-state`
- a fila de comandos dos widgets fica em `${XDG_RUNTIME_DIR}/quickshell-state/commands`
- caches do Quickshell ficam em `${XDG_CACHE_HOME:-~/.cache}/quickshell`
- logs de bootstrap do Quickshell ficam em `${XDG_CACHE_HOME:-~/.cache}/quickshell/main.log` e `${XDG_CACHE_HOME:-~/.cache}/quickshell/topbar.log`
- a pasta padrao de wallpapers e `~/Wallpapers`
- `waybar` nao faz mais parte do fluxo do Hyprland atual
- testes de shell do manager/startup/workspaces ficam em `repos/dotfiles/tests/quickshell/run.sh`

## Integracoes opcionais

- `easyeffects`
- `mpvpaper`
- `swaync`
- weather real com credenciais locais
- agenda real com fonte de dados do usuario
- diario do Obsidian com paths locais definitivos

## Pendencias praticas

- validar `monitors` com duas telas fisicas
- revisar polish visual dos popups e da barra
- decidir se `stewart` fica como widget visual, sai, ou ganha funcao real
- fazer um passe de limpeza adicional nos extras de calendario se eles forem ativados de verdade
