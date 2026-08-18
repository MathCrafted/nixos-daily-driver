{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home.url = "github:nix-community/home-manager/release-26.05";
    sops.url = "github:Mic92/sops-nix";
  };
  outputs = inputs@{ self, nixpkgs, home, sops, ... }: {
    nixosConfigurations.gandalf = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };
    in nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./gandalf/configuration.nix
        home.nixosModules.home-manager
      ];
    };
    nixosConfigurations.compose = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./vms/base.nix
        sops.nixosModules.sops
      ];
    };
    nixosConfigurations.ldap = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./vms/base.nix
        ./vms/auth.nix
        sops.nixosModules.sops
      ];
    };
  };
}
