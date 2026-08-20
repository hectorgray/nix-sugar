{ lib, ... }:

{
  flake.lib.listTree = root: let
    rules = p:
      lib.hasSuffix ".nix" p
      && !(lib.hasInfix "/_" p)
      && !(lib.hasInfix "/." p)
      && baseNameOf p != "flake.nix";
  in root
    |> lib.filesystem.listFilesRecursive
    |> map toString
    |> builtins.filter rules;
}
