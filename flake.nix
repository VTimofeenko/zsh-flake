{
  description = "Flake with the module containing my zsh config";

  outputs = { self, nixpkgs }: {
    nixosModule = import ./module.nix;
  };
}
