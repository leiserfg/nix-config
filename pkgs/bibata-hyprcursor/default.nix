{
  lib,
  stdenvNoCC,
  fetchurl,
  bibata-cursors,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bibata-hyprcursor";

  inherit (bibata-cursors) version;

  src = fetchurl {
    url = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/1.0/hypr_Bibata-Original-Classic.tar.gz";
    hash = "sha256-y4yRJYTI9uf/sbIJxwi0bZxgsiAXykn253qgDkHZa7g=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    cp -r $PWD $out/share/icons

    runHook postInstall
  '';

  meta = {
    description = "Open source, compact, and material designed cursor set";
    homepage = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [fufexan];
  };
})
