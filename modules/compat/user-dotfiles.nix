{ pkgs, ... }:
{
  system.activationScripts.userDotfilesCompat.text = ''
    install -d -m 0755 -o fmazzuco -g users /home/fmazzuco/.zsh/plugins
    ln -sfn ${pkgs.zsh-autocomplete}/share/zsh-autocomplete /home/fmazzuco/.zsh/plugins/zsh-autocomplete
    chown -h fmazzuco:users /home/fmazzuco/.zsh/plugins/zsh-autocomplete
  '';

  system.activationScripts.codexBubblewrapCompat.text = ''
    install -d -m 0755 /usr/bin
    ln -sfn ${pkgs.bubblewrap}/bin/bwrap /usr/bin/bwrap
  '';
}
