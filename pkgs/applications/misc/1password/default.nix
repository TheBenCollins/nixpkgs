{ lib, stdenv, fetchurl, fetchzip, autoPatchelfHook, installShellFiles, cpio, xar }:

let
  inherit (stdenv.hostPlatform) system;
  fetch = srcPlatform: sha256: extension:
    let
      args = {
        url = "https://cache.agilebits.com/dist/1P/op2/pkg/v${version}/op_${srcPlatform}_v${version}.${extension}";
        inherit sha256;
      } // lib.optionalAttrs (extension == "zip") { stripRoot = false; };
    in
    if extension == "zip" then fetchzip args else fetchurl args;

  pname = "1password-cli";
  version = "2.0.0";
  sources = rec {
    aarch64-linux = fetch "linux_arm64" "sha256-NhCs68on8LzoeOmM5eP8LwmFaVWz6aghqtHzfUlACiA=" "zip";
    i686-linux = fetch "linux_386" "sha256-vCxgEBq4YVfljq2zUpvBdZUbIiam4z64P1m9OMWq1f4=" "zip";
    x86_64-linux = fetch "linux_amd64" "sha256-CDwrJ5ksXf9kwHobw4jvRUi1hLQzq4/yRlk+kHPN7UE=" "zip";
    aarch64-darwin = fetch "apple_universal" "sha256-DC9hdzRjQ9iNjbe6PfRpMXzDeInq4rYSAa2nDHQMTRo=" "pkg";
    x86_64-darwin = aarch64-darwin;
  };
  platforms = builtins.attrNames sources;
  mainProgram = "op";
in

stdenv.mkDerivation {
  inherit pname version;
  src =
    if (builtins.elem system platforms) then
      sources.${system}
    else
      throw "Source for ${pname} is not available for ${system}";

  nativeBuildInputs = [ installShellFiles ] ++ lib.optional stdenv.isLinux autoPatchelfHook;

  buildInputs = lib.optionals stdenv.isDarwin [ xar cpio ];

  unpackPhase = lib.optionalString stdenv.isDarwin ''
    xar -xf $src
    zcat op.pkg/Payload | cpio -i
  '';

  installPhase = ''
    install -D ${mainProgram} $out/bin/${mainProgram}
    runHook postInstall
  '';

  postInstall = "installShellCompletion --cmd ${mainProgram}" + lib.concatMapStrings
    (s: " --${s} <($out/bin/${mainProgram} completion ${s})") [ "bash" "fish" "zsh" ];

  dontStrip = stdenv.isDarwin;

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/${mainProgram} --version
  '';

  meta = with lib; {
    description = "1Password command-line tool";
    homepage = "https://developer.1password.com/docs/cli/";
    downloadPage = "https://app-updates.agilebits.com/product_history/CLI2";
    maintainers = with maintainers; [ joelburget marsam ];
    license = licenses.unfree;
    inherit mainProgram platforms;
  };
}
