{ config, pkgs, lib, ... }:

let
  nixos-unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  packages_toml = lib.importTOML ./packages.toml;
  packages = {
    stable = map (x: lib.getAttrFromPath (lib.splitString "." x) pkgs) packages_toml.stable.packages;
    unstable = map (x: lib.getAttrFromPath (lib.splitString "." x) nixos-unstable) packages_toml.unstable.packages;
  };
in
{
  environment.systemPackages = packages.stable ++ packages.unstable;
}
