{ pkgs, config, ... }:
let
  userName = config.workstation.userName;
  userHome = config.workstation.userHome;
in
{
  system.activationScripts.userDotfilesCompat.text = ''
    install -d -m 0755 -o ${userName} -g users ${userHome}/.zsh/plugins
    ln -sfn ${pkgs.zsh-autocomplete}/share/zsh-autocomplete ${userHome}/.zsh/plugins/zsh-autocomplete
    chown -h ${userName}:users ${userHome}/.zsh/plugins/zsh-autocomplete
  '';

  system.activationScripts.codexBubblewrapCompat.text = ''
    install -d -m 0755 /usr/bin
    ln -sfn ${pkgs.bubblewrap}/bin/bwrap /usr/bin/bwrap
  '';
}
