{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation {
  pname = "wwan-manager";
  version = "1.1";

  src = fetchurl {
    url = "https://github.com/patriczeq/WWANManager/releases/download/1.1/WWANManager.zip";
    hash = "sha256-cgOFCBVOGA3c34SBIUdMODjVwm/OFLb0LO8lWVcuYkU=";
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
    description = "WWAN and serial PPP connection manager for macOS";
    homepage = "https://github.com/patriczeq/WWANManager";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
