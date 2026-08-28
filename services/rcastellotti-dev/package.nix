{
  buildGoModule,
  lib,
}:
buildGoModule {
  pname = "rcastellotti-dev";
  version = "0.1.0";
  src = ./.;
  vendorHash = "sha256-SkdmafcC4+9na0BNxK3/34FRIlA4Uc8R2/9Ha3D124s=";

  postInstall = ''
    mv $out/bin/www $out/bin/rcastellotti-dev
  '';

  meta = {
    description = "Roberto Castellotti's personal website";
    homepage = "https://rcastellotti.dev";
    license = lib.licenses.mit;
    mainProgram = "rcastellotti-dev";
  };
}
