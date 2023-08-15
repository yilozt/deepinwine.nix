{
  description = "Flake to run Deepin Wine6 Stable";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/b7cde1c47b7316f6138a2b36ef6627f3d16d645c";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux = import ./apps.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };

    overlays.default = final: prev: import ./apps.nix { pkgs = final; };
  };
}
