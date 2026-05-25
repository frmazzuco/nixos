{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  mt7902KernelPackages = pkgs.linuxPackages_latest;
  mt7902Kernel = mt7902KernelPackages.kernel;
  mt7902ModDirVersion = mt7902Kernel.modDirVersion;
  mt7902SourceVersion = inputs.mt7902-temp.shortRev or "source";
  mt7902SourceSubdir = "linux-6.19/drivers/net/wireless/mediatek/mt76";

  mt7902Firmware = pkgs.runCommand "mt7902-firmware-${mt7902SourceVersion}" { } ''
    install -Dm644 ${inputs.mt7902-temp}/firmware/WIFI_MT7902_patch_mcu_1_1_hdr.bin \
      $out/lib/firmware/mediatek/WIFI_MT7902_patch_mcu_1_1_hdr.bin
    install -Dm644 ${inputs.mt7902-temp}/firmware/WIFI_RAM_CODE_MT7902_1.bin \
      $out/lib/firmware/mediatek/WIFI_RAM_CODE_MT7902_1.bin
    install -Dm644 ${inputs.mt7902-temp}/firmware/BT_RAM_CODE_MT7902_1_1_hdr.bin \
      $out/lib/firmware/mediatek/BT_RAM_CODE_MT7902_1_1_hdr.bin
    install -Dm644 ${inputs.mt7902-temp}/firmware/BT_RAM_CODE_MT7902_1_1_hdr.bin.zst \
      $out/lib/firmware/mediatek/BT_RAM_CODE_MT7902_1_1_hdr.bin.zst
  '';

  mt7902Modules = pkgs.stdenv.mkDerivation {
    pname = "mt7902-mt76-modules";
    version = "unstable-${mt7902SourceVersion}";
    src = inputs.mt7902-temp;
    sourceRoot = "source/${mt7902SourceSubdir}";

    nativeBuildInputs = mt7902Kernel.moduleBuildDependencies;

    buildPhase = ''
      runHook preBuild
      make -C ${mt7902Kernel.dev}/lib/modules/${mt7902ModDirVersion}/build M=$PWD modules
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm644 mt76.ko \
        $out/lib/modules/${mt7902ModDirVersion}/extra/mt7902/mt76.ko
      install -Dm644 mt76-connac-lib.ko \
        $out/lib/modules/${mt7902ModDirVersion}/extra/mt7902/mt76-connac-lib.ko
      install -Dm644 mt792x-lib.ko \
        $out/lib/modules/${mt7902ModDirVersion}/extra/mt7902/mt792x-lib.ko
      install -Dm644 mt7921/mt7921-common.ko \
        $out/lib/modules/${mt7902ModDirVersion}/extra/mt7902/mt7921-common.ko
      install -Dm644 mt7921/mt7921e.ko \
        $out/lib/modules/${mt7902ModDirVersion}/extra/mt7902/mt7921e.ko
      runHook postInstall
    '';
  };

  modulePath =
    module: "${mt7902Modules}/lib/modules/${mt7902ModDirVersion}/extra/mt7902/${module}.ko";
in
{
  assertions = [
    {
      assertion = lib.hasPrefix "6.19." mt7902ModDirVersion;
      message = "O driver MT7902 empacotado aqui usa a arvore linux-6.19 do mt7902_temp; atualize o subdiretorio junto com o kernel.";
    }
  ];

  boot.kernelPackages = mt7902KernelPackages;
  boot.extraModulePackages = [ mt7902Modules ];
  boot.blacklistedKernelModules = [ "mt7902" ];
  hardware.firmware = [ mt7902Firmware ];
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = lib.mkAfter ''
    options cfg80211 ieee80211_regdom=BR
  '';

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

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
      running_kernel="$(uname -r)"
      if [ "$running_kernel" != "${mt7902ModDirVersion}" ]; then
        echo "Driver MT7902 compilado para ${mt7902ModDirVersion}; kernel ativo e $running_kernel. Reinicie para carregar o kernel compatível." >&2
        exit 0
      fi

      modprobe cfg80211
      modprobe mac80211
      modprobe rfkill || true

      rmmod mt7902 mt7921e mt7921_common mt792x_lib mt76_connac_lib mt76 2>/dev/null || true

      insmod ${modulePath "mt76"}
      insmod ${modulePath "mt76-connac-lib"}
      insmod ${modulePath "mt792x-lib"}
      insmod ${modulePath "mt7921-common"}
      insmod ${modulePath "mt7921e"}
    '';
  };
}
