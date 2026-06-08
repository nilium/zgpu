{
  description = "Cross-platform graphics lib for Zig built on top of wgpu-native WebGPU implementation.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            just
            zig_0_16
            zls_0_16
            wgpu-native
            wgpu-native.dev
          ];
        };

        formatter = pkgs.nixfmt;
      }
    );
}
