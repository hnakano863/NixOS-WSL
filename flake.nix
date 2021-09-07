{
  description = "NixOS WSL";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }: { nixosModule = import ./configuration.nix; };
}
