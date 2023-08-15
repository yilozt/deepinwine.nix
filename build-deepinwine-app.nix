{ dpkg
, callPackage
, stdenv
, makeWrapper
, lib
, pkgs
, callPackage_i686
, python3
, p7zip
, toybox
, gnome
, desktop-file-utils
, pname
, version
, src
}:
let
  deepin-wine6-stable = callPackage ./deepin-wine6-stable.nix { };
  deepin-runtime = callPackage_i686 ./deepin-wine-runtime.nix { };
  pythonEnv = python3.withPackages (p: with p; [ dbus-python ]);
in

stdenv.mkDerivation (finalAttrs: {
  inherit pname version src;

  unpackCmd = "for s in $src; do dpkg -x $s .; done";
  sourceRoot = ".";

  buildInputs = (import ./deps.nix { Pkgs = pkgs; });

  nativeBuildInputs = [ dpkg makeWrapper desktop-file-utils ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    mkdir $out/opt
    app_dir=$out/opt/apps/${finalAttrs.pname}

    cp -rv ./usr/* $out/
    cp -rv ./opt/apps $out/opt/
    cp -rv ./opt/deepinwine/tools $app_dir/
    mv -v $app_dir/entries/{applications,icons} $out/share/
    rm -rf $app_dir/entries
    rm -v $app_dir/tools/box86-activex
    rm -v $app_dir/tools/run_activex.sh

    entry_file=$out/share/applications/${finalAttrs.pname}.desktop
    sed -i 's?#!/usr/bin/env xdg-open??' $entry_file
    substituteInPlace $entry_file \
      --replace /opt/apps/ $out/opt/apps/
    set +x
    runHook postInstall
  '';

  rpath = lib.makeLibraryPath finalAttrs.buildInputs;

  postFixup = ''
    helper_prefix=$app_dir/tools
  
    for file in $app_dir/files/dlls/* ; do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath ${finalAttrs.rpath}:${stdenv.cc.cc.lib}/lib "$file" || true
    done
    
    for file in $app_dir/files/run.sh $helper_prefix/*.sh; do
      substituteInPlace $file \
        --replace /opt/apps/ $out/opt/apps/ \
        --replace /opt/deepinwine/tools $helper_prefix \
        --replace WINEPREDLL=\"\$ARCHIVE_FILE_DIR/dlls\" WINEPREDLL=\"$app_dir/files/dlls\"
    done

    wrapProgram $helper_prefix/get_tray_window \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"
    wrapProgram $app_dir/files/run.sh \
      --prefix PATH : ${lib.makeBinPath [ toybox p7zip gnome.zenity deepin-wine6-stable ]}

    mkdir $out/bin
    # link to deepin-wine6-stable
    ln -sf ${deepin-wine6-stable}/bin/deepin-wine6-stable $out/bin/wine.${pname}
    # link to run script
    ln -sf $app_dir/files/run.sh $out/bin/${pname}
  '';
})
# test -e $app_dir/files/dlls/wineserver && substituteInPlace $app_dir/files/dlls/wineserver \
#   --replace runtime_path=/opt/deepinwine/ runtime_path=${deepin-runtime}/opt/deepinwine/
