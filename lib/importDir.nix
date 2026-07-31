{ lib, ... }:

{
  flake.lib.importDir = dir: let
    rules = p:
      lib.hasSuffix ".nix" p
      && !(lib.hasInfix "/_" p)
      && !(lib.hasInfix "/." p)
      && baseNameOf p != "flake.nix";
  in dir
    |> lib.filesystem.listFilesRecursive
    |> map toString
    |> builtins.filter rules;
}
