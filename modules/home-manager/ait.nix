{ config, pkgs, lib, ... }:
let
  updater = pkgs.writeShellScript "ait-update" ''
    exec ${pkgs.python3}/bin/python3 ${../../scripts/ait-update.py} "$@"
  '';
in
{
  # Resolve the rolling ait-app/ait nightly at runtime and verify its
  # checksum: its release assets change without changing the nightly tag.
  home.file.".local/bin/ait-update".source = updater;
  home.activation.updateAit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${updater}
  '';
  launchd.agents.ait-update = {
    enable = true;
    config = {
      ProgramArguments = [ "${updater}" ];
      RunAtLoad = true;
      StartInterval = 86400;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/ait-update.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/ait-update.error.log";
    };
  };
}
