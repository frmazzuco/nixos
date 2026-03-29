{ pkgs, ... }:
{
  boot.swraid = {
    enable = true;
    mdadmConf = ''
      PROGRAM ${pkgs.coreutils}/bin/true
      AUTO +all
      ARRAY /dev/md127 metadata=1.2 UUID=97eba8d8:75a29d0c:0246fa54:bb7be45e
    '';
  };

  fileSystems."/mnt/orico-storage" = {
    device = "/dev/md127";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.automount"
      "x-systemd.device-timeout=10s"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/orico-storage 0755 root root -"
  ];
}
