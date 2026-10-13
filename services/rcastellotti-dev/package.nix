{ hugo, lib, stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "rcastellotti-dev";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [ hugo ];

  buildPhase = ''
    runHook preBuild
    hugo --minify --destination $out
    runHook postBuild
  '';

  dontInstall = true;

  meta = {
    description = "Roberto Castellotti's personal website";
    homepage = "https://rcastellotti.dev";
    license = lib.licenses.mit;
  };
}
