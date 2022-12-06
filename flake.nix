{
  description = "Flake with the module containing my zsh config";
  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";

  outputs = { self, nixpkgs }: {
    nixosModule = import ./module.nix;
  };
}
