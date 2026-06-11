# Fronteira de responsabilidade: o NixOS e dono do symlink
# ~/.zsh/plugins/zsh-autocomplete de proposito, porque o alvo e um caminho da
# nix store que o repo de dotfiles (stow) nao consegue prover. O .zshrc dos
# dotfiles faz source desse arquivo atras de um guard -r. Todo o resto dos
# dotfiles do usuario e de responsabilidade de ~/repos/dotfiles via stow --
# nao adicione mais gerenciamento de dotfiles de usuario aqui.
{ pkgs, config, ... }:
let
  userName = config.workstation.userName;
  userHome = config.workstation.userHome;
in
{
  system.activationScripts.userDotfilesCompat.text = ''
    install -d -m 0755 -o ${userName} -g users ${userHome}/.zsh
    install -d -m 0755 -o ${userName} -g users ${userHome}/.zsh/plugins
    ln -sfn ${pkgs.zsh-autocomplete}/share/zsh-autocomplete ${userHome}/.zsh/plugins/zsh-autocomplete
    chown -h ${userName}:users ${userHome}/.zsh/plugins/zsh-autocomplete
  '';

  system.activationScripts.codexBubblewrapCompat.text = ''
    install -d -m 0755 /usr/bin
    ln -sfn ${pkgs.bubblewrap}/bin/bwrap /usr/bin/bwrap
  '';
}
