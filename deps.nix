{ Pkgs
, Pkgs2105 ? ((builtins.getFlake "github:NixOS/nixpkgs/7e9b0dff974c89e070da1ad85713ff3c20b0ca97").legacyPackages.${Pkgs.stdenv.system})
}:
(with Pkgs;
[
  atk
  gdk-pixbuf
  libxkbcommon
  glib
  glibc
  ncurses
  cairo
  alsaLib
  udev
  libpcap
  libpulseaudio
  khronos-ocl-icd-loader
  lcms2
  libjpeg
  gtk3
  freetype
  fontconfig
  libgphoto2
  libkrb5
  pango
  dbus
  libusb
  libunwind
  cups
  mpg123
  mesa
  openal
  xorg.libX11
  xorg.libXext
  xorg.libxkbfile
  xorg.libXcomposite
  xorg.libXcursor
  xorg.libXdamage
  xorg.libXfixes
  xorg.libXi
  xorg.libXrandr
  xorg.libXrender
  xorg.libXxf86vm
  xorg.libXtst
  xorg.libxcb
  lcms2
  libxml2
  gst_all_1.gstreamer
  gst_all_1.gst-plugins-base
  gst_all_1.gst-plugins-good
  gst_all_1.gst-plugins-ugly
  gst_all_1.gst-libav
  gst_all_1.gst-plugins-bad
]) ++ (
  let
    pkgs = Pkgs2105;
    pkgsi686Linux = pkgs.pkgsi686Linux;
  in
  [
    pkgs.openldap
    pkgsi686Linux.openldap

    pkgs.udis86
    pkgsi686Linux.udis86
  ]
)
