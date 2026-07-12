{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation {
  pname = "wwan-manager";
  version = "1.3.0-rc.1";

  src = fetchurl {
    url = "https://github.com/KirisameLonnet/qdc507-wwan-manager/releases/download/v1.3.0-rc.1/WWANManager-1.3.0-macos-universal.zip";
    hash = "sha256-qzDRyG6bK68tBJAdHtZTwC29ilkrBjr6YlcMUV/qPTc=";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R WWANManager.app "$out/Applications/"

    runHook postInstall
  '';

  meta = {
    description = "QDC507 WWAN and serial PPP connection manager for macOS";
    homepage = "https://github.com/KirisameLonnet/qdc507-wwan-manager";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
