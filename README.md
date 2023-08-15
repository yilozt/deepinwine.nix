## deepinwine.nix

用来跑 `deepin-wine6-stable` 的 Nix Flake，目前只添加了自己常用的应用

### Try it in the shell!

```console
nix run "github:yilozt/deepinwine.nix#wechat"
```

### 应用列表

[./apps.nix](./apps.nix)

| 应用     | 包名   |
|:---------|:-------|
| 企业微信 | wxwork |
| QQ       | QQ     |
| 微信     | wechat |

### Usage

添加到 Flake 中：

```nix
{
  inputs.deepin-wine.url = "github:yilozt/deepinwine.nix";

  outputs = { self, nixpkgs, deepin-wine }:
    let system = "x86_64-linux";
    in {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ ... }: {
            # 使用 flake 提供的包
            environment.systemPackages =
              [ deepin-wine.legacyPackages.${system}.wechat ];

            # 或者使用 overlay，将包导入到 nixpkgs 列表里
            nixpkgs.overlays = [ deepin-wine.overlays.default ];
            environment.systemPackages = [ wechat ];
          })
        ];
      };
    };
}
```

