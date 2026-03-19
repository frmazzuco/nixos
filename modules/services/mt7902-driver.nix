{ pkgs, ... }:
let
  driverDirectory = "/home/fmazzuco/mt7902-driver";
in
{
  networking.networkmanager.enable = true;

  environment.etc."NetworkManager/conf.d/90-wifi-mac.conf".text = ''
    [device]
    wifi.scan-rand-mac-address=no

    [connection]
    wifi.cloned-mac-address=permanent
  '';

  systemd.services.mt7902-driver = {
    description = "Load MT7902 Wi-Fi driver";
    wantedBy = [ "multi-user.target" ];
    before = [ "NetworkManager.service" ];
    after = [
      "local-fs.target"
      "systemd-modules-load.service"
    ];
    path = with pkgs; [
      coreutils
      kmod
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      install -Dm644 "${driverDirectory}/WIFI_MT7902_patch_mcu_1_1_hdr.bin" /lib/firmware/mediatek/mt7902/WIFI_MT7902_patch_mcu_1_1_hdr.bin
      install -Dm644 "${driverDirectory}/WIFI_RAM_CODE_MT7902_1.bin" /lib/firmware/mediatek/mt7902/WIFI_RAM_CODE_MT7902_1.bin
      install -Dm644 "${driverDirectory}/EEPROM_MT7902_1.bin" /lib/firmware/mediatek/mt7902/EEPROM_MT7902_1.bin
      install -Dm644 "${driverDirectory}/wifi.cfg" /lib/firmware/mediatek/mt7902/wifi.cfg
      install -Dm644 "${driverDirectory}/WIFI_MT7902_patch_mcu_1_1_hdr.bin" /lib/firmware/mediatek/WIFI_MT7902_patch_mcu_1_1_hdr.bin
      install -Dm644 "${driverDirectory}/WIFI_RAM_CODE_MT7902_1.bin" /lib/firmware/mediatek/WIFI_RAM_CODE_MT7902_1.bin
      modprobe cfg80211
      rmmod mt7902 2>/dev/null || true
      insmod "${driverDirectory}/mt7902.ko"
    '';
  };
}
