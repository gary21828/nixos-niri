{
  description = "NixOS niri config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Used only for latest packages
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      hostname = "nixos";
      username = "gary";
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit hostname username;
        };

        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";

              extraSpecialArgs = {
                inherit inputs;
              };

              users.${username} = import ./home.nix;
            };
          }
        ];
      };
    };
}
