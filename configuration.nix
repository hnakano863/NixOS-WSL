{ lib, pkgs, config, ... }:

with lib; let cfg = config.wsl2; in
{
  options.wsl2.enable = mkEnableOption "WSL2";
  options.wsl2.defaultUser = mkOption {
    type = types.str;
    example = "nixos";
    description = ''
      Default user name of WSL2
    '';
  };

  config = let
    syschdemd = import ./syschdemd.nix {
      inherit lib pkgs config;
      inherit (cfg) defaultUser;
    };
  in mkIf cfg.enable {

    # WSL is closer to a container than anything else
    boot.isContainer = true;

    environment.etc.hosts.enable = false;
    environment.etc."resolv.conf".enable = false;

    networking.dhcpcd.enable = false;

    users.users.root = {
      shell = "${syschdemd}/bin/syschdemd";
      # Otherwise WSL fails to login as root with "initgroups failed 5"
      extraGroups = [ "root" ];
    };

    # Disable systemd units that don't make sense on WSL
    systemd.services."serial-getty@ttyS0".enable = false;
    systemd.services."serial-getty@hvc0".enable = false;
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@".enable = false;

    systemd.services.firewall.enable = false;
    systemd.services.systemd-resolved.enable = false;
    systemd.services.systemd-udevd.enable = false;
    systemd.services.systemd-pstore.enable = false;

    # Don't allow emergency mode, because we don't have a console.
    systemd.enableEmergencyMode = false;
  };
}
