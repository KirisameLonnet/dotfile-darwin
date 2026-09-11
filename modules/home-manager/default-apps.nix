# Default Application Associations
#
# macOS stores these in the LaunchServices database, which nix cannot write
# declaratively. `duti` is the supported CLI for it, driven from a home-manager
# activation step so the bindings are reasserted on every switch.
{ config, pkgs, lib, ... }:

let
  vlc = "org.videolan.vlc";

  videoExtensions = [
    "3gp" "asf" "avi" "divx" "f4v" "flv" "m2ts" "m2v" "m4v" "mkv"
    "mov" "mp4" "mpeg" "mpg" "mts" "ogv" "rm" "rmvb" "ts" "vob"
    "webm" "wmv"
  ];

  audioExtensions = [
    "aac" "aiff" "ape" "dsf" "flac" "m4a" "mka" "mp3" "oga" "ogg"
    "opus" "wav" "wma" "wv"
  ];

  mediaExtensions = videoExtensions ++ audioExtensions;
in
{
  home.packages = [ pkgs.duti ];

  # Bind every media extension to VLC. duti is idempotent, so re-running on
  # each activation just re-affirms the existing binding.
  home.activation.setDefaultMediaPlayer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d /Applications/VLC.app ]; then
      echo "default-apps: /Applications/VLC.app not found, skipping media handlers"
    else
      failed=""
      for ext in ${lib.escapeShellArgs mediaExtensions}; do
        ${pkgs.duti}/bin/duti -s ${vlc} "$ext" all 2>/dev/null || failed="$failed $ext"
      done
      if [ -n "$failed" ]; then
        echo "default-apps: could not bind to VLC:$failed"
      fi
    fi
  '';
}
