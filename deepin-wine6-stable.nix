{ stdenv
, multiStdenv
, lib
, dpkg
, pkgs
, pkgsi686Linux
, fetchurl
, makeWrapper
}:

let
  pkg_name = "deepin-wine6-stable";
  version = "6.0.0.52-1";
  src = [
    (fetchurl {
      urls = [ "https://com-store-packages.uniontech.com/appstore/pool/appstore/d/deepin-wine6-stable/deepin-wine6-stable_${version}_amd64.deb" ];
      sha256 = "sha256-/RoyiqOBfrH4o2FMYvjXdQC9ozYUpFZAaH0vwxfBftI=";
    })
  ];
  unpackCmd = "for s in $src; do dpkg -x $s .source; done";
  sourceRoot = ".source";
in
multiStdenv.mkDerivation rec
{
  pname = "deepin-wine6-stable";
  inherit src version pkg_name unpackCmd sourceRoot;

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];
  buildInputs = [
    (import ./deps.nix { Pkgs = pkgs; })
    (import ./deps.nix { Pkgs = pkgsi686Linux; })
  ];
  rpath64 = lib.makeLibraryPath (import ./deps.nix { Pkgs = pkgs; });
  rpath32 = lib.makeLibraryPath (import ./deps.nix { Pkgs = pkgsi686Linux; });


  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -r ./usr/* $out/
    cp -r ./opt   $out/

    substituteInPlace $out/bin/$pkg_name \
      --replace wine32=/opt/\$name/ wine32=$out/opt/\$name/ \
      --replace wine64=/opt/\$name/ wine64=$out/opt/\$name/ \
      --replace WINEDLLPATH=/opt/\$name/lib:/opt/\$name/lib64 WINEDLLPATH=\$WINEDLLPATH:$out/opt/\$name/lib:$out/opt/\$name/lib64 \
      --replace /opt/\$name/bin/wine-preloader $out/opt/\$name/bin/wine-preloader \
      --replace \$name $pkg_name
    runHook postInstall
  '';

  postFixup = ''
    preFix=$out/opt/$pkg_name

    for file in $preFix/lib64/*.so $preFix/bin/{widl,wine64,wine64-preloader,winebuild,winedump,winegcc,wineserver,wmc,wrc}; do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath ${rpath64}:${stdenv.cc.cc.lib}/lib64 $file || true
    done

    for file in $preFix/lib/*.so $preFix/bin/{wine,wine-preloader}; do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker-m32)" "$file" || true
      patchelf --set-rpath ${rpath32}:${pkgsi686Linux.stdenv.cc.cc.lib}/lib $file || true
    done

    wrapProgram $out/bin/$pkg_name \
      --prefix LD_LIBRARY_PATH : ${rpath32}:${rpath64} \
      --set ATTACH_FILE_DIALOG 0
  '';
}
