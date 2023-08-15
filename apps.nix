{ pkgs }:
with pkgs; let
  buildWineApp = { pname, src, version }:
    callPackage ./build-deepinwine-app.nix {
      inherit pname src version;
    };

  deepin-wine-helper = fetchurl {
    url = "https://com-store-packages.uniontech.com/appstore/pool/appstore/d/deepin-wine-helper/deepin-wine-helper_5.2.28-1_amd64.deb";
    sha256 = "sha256-u5gbJIGIenjkApTg0P2YQvzTrk0SPEhUuQSKY9mpW+0=";
  };

  buildSrc = src: [ src deepin-wine-helper ];

in
{
  # 微信
  wechat = buildWineApp rec {
    pname = "com.qq.weixin.deepin";
    version = "3.7.0.30deepin24_i386";
    src = buildSrc (fetchurl {
      url = "https://com-store-packages.uniontech.com/appstore/pool/appstore/c/${pname}/${pname}_${version}.deb";
      sha256 = "sha256-zbLYN6JzRBBmuOrmUw62v62rce5kYIN4+BUF+ojnbtU=";
    });
  };

  # 企业微信
  wxwork = buildWineApp rec {
    pname = "com.qq.weixin.work.deepin";
    version = "4.1.6.6017deepin6";
    src = buildSrc (fetchurl {
      url = "https://com-store-packages.uniontech.com/appstore/pool/appstore/c/${pname}/${pname}_${version}_i386.deb";
      sha256 = "sha256-RSLYgmsC5YwlziUGAA1vO9KEq9UXuMqGQGyOlVv0Bes=";
    });
  };

  # QQ
  QQ = buildWineApp rec {
    pname = "com.qq.im.deepin";
    version = "9.5.3.28008deepin33";
    src = buildSrc (fetchurl {
      url = "https://com-store-packages.uniontech.com/appstore/pool/appstore/c/${pname}/${pname}_${version}_i386.deb";
      sha256 = "sha256-d0rFSMrTSlppsz9Ubhzyoqh/I/GPyKE0DHk6H7k+Su0=";
    });
  };

}
