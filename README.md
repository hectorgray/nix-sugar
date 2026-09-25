# Nix Sugar

Miscellaneous Nix expressions.

## Requirements

Ensure the following are enabled in your Nix configuration:

```nix
nix.settings.experimental-features = [
  "flakes"
  "nix-command"
  "pipe-operators"
];
```

Then add to your inputs:

```nix
inputs.sugar = {
  url = "github:hectorgray/nix-sugar";

  # Optional
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-parts.follows = "flake-parts";
};
```

## Functions

### `listTree`

```
listTree :: Path -> [String]
```

Recursively list all `.nix` files under a directory, skipping `flake.nix` and
paths prefixed with `.` or `_`.

#### Example

```nix
outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  systems = [ "x86_64-linux" ];
  imports = inputs.sugar.lib.listTree ./.;
};
```

> [!NOTE]
> Examples below may assume this flake setup (`flake-parts` + `listTree`),
> though the features should still work without it.

**Related:**

- [denful/import-tree](https://github.com/denful/import-tree)

## Flake Modules

### `easyLib`

```nix
imports = [ inputs.sugar.flakeModules.easyLib ];
```

Merge `flake.lib` across modules as a lazy attribute set of functions
(type-checked), so any module can contribute one without declaring an option
for it. Two modules contributing the same name is an error.

This is a plain module designed to work well with `flake-parts`, which exposes
`flake.lib` as the output `lib`.

#### Example

```nix
# greet.nix
{ flake.lib.greet = name: "Hello, ${name}!"; }
```

```nix
# square.nix
{ flake.lib.square = x: x * x; }
```

## Home Modules

### `mutableFiles`

```nix
imports = [ inputs.sugar.homeModules.mutableFiles ];
```

Install `home.file` and `xdg.*File` entries as writable copies. Edits last
until the next Home-Manager activation, which restores the declared contents.

#### Example

```nix
xdg.configFile."VSCodium/User/settings.json" = {
  mutable = true;

  source = (pkgs.formats.json {}).generate "vscodium-settings.json" {
    "editor.tabSize" = 2;
    "workbench.startupEditor" = "newUntitledFile";
  };
};
```

## Archive

Files in `_archive/` are kept for reference and are not included in this
flake's outputs.

### Home Modules

- `mimeGlobs`: upstreamed in nix-community/home-manager#9883
