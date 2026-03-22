{ lib, ... }:
let
  userName = "fmazzuco";
  userHome = "/home/${userName}";
in
{
  options.workstation = {
    userName = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = userName;
      description = "Primary workstation user account name.";
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "Francisco Mazzuco Filho";
      description = "Display name for the primary workstation user.";
    };

    userHome = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = userHome;
      description = "Home directory for the primary workstation user.";
    };

    repoRoot = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "${userHome}/repos";
      description = "Root directory for local source checkouts on the workstation.";
    };
  };
}
