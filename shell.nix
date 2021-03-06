{ pkgs ? import <nixpkgs> { } }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
pkgs.mkShell {
  buildInputs = [
    unstable.cargo
    unstable.rustc
    pkgs.python3Packages.toml
    pkgs.bashInteractive
  ];
}
