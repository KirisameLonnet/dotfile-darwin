{ config, pkgs, lib, ... }:

let
  appName = "Lan Mouse";
  bundleId = "com.lonnetkirisame.lan-mouse";
  version = lib.getVersion pkgs.lan-mouse;
  appPath = "/Applications/${appName}.app";

  lanMouseApp = pkgs.stdenvNoCC.mkDerivation {
    pname = "lan-mouse-app";
    version = version;
    dontUnpack = true;
    installPhase = ''
      app="$out/Applications/${appName}.app"
      mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
      cp ${pkgs.lan-mouse}/bin/lan-mouse "$app/Contents/MacOS/lan-mouse"
      chmod +x "$app/Contents/MacOS/lan-mouse"
      cat > "$app/Contents/Info.plist" <<'PLIST'
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleName</key>
        <string>Lan Mouse</string>
        <key>CFBundleDisplayName</key>
        <string>Lan Mouse</string>
        <key>CFBundleIdentifier</key>
        <string>${bundleId}</string>
        <key>CFBundleExecutable</key>
        <string>lan-mouse</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>${version}</string>
        <key>CFBundleVersion</key>
        <string>${version}</string>
        <key>LSUIElement</key>
        <true/>
      </dict>
      </plist>
      PLIST
      echo "APPL????" > "$app/Contents/PkgInfo"
    '';
  };

  lanMouseWrapper = pkgs.writeShellScriptBin "lan-mouse" ''
    app_bin="${appPath}/Contents/MacOS/lan-mouse"
    if [ ! -x "$app_bin" ]; then
      echo "Lan Mouse.app not installed. Run 'darwin-rebuild switch'." >&2
      exit 1
    fi
    exec "$app_bin" "$@"
  '';
in
{
  environment.systemPackages = [
    lanMouseWrapper
  ];

  launchd.user.agents.lan-mouse = {
    serviceConfig = {
      ProgramArguments = [
        "/run/current-system/sw/bin/lan-mouse"
        "--frontend"
        "cli"
      ];
      EnvironmentVariables = {
        XDG_CONFIG_HOME = "/Users/lonnetkirisame/.config";
      };
      RunAtLoad = true;
    };
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    app_src="${lanMouseApp}/Applications/${appName}.app"
    app_dst="${appPath}"

    if [ -e "$app_dst" ]; then
      rm -rf "$app_dst"
    fi

    /usr/bin/ditto "$app_src" "$app_dst"
    /usr/sbin/chown -R root:wheel "$app_dst"
    /bin/chmod -R go-w "$app_dst"
  '';
}
