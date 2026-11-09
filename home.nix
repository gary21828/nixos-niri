{ pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
  };

  flake = "$HOME/nixos-dotfiles";

in
{
  home = {
    stateVersion = "26.05";

    packages = (with pkgs; [
      htop
      ripgrep
      fd
      jq
      unzip
      p7zip
      adwaita-icon-theme
      papirus-icon-theme
    ]) ++ [ unstable.opencode ];
  };

  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.librewolf.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      update = "nix flake update --flake ${flake} && sudo nixos-rebuild switch --flake ${flake}#nixos";
      rebuild = "sudo nixos-rebuild switch --flake ${flake}#nixos";
      cleanup = "sudo nix-collect-garbage --delete-older-than 15d";
      optimise = "nix store optimise";
      search = "nix search nixpkgs";
      generations = "nixos-rebuild list-generations";
    };
  };

  # Full home.nix is large; this is a placeholder push to complete the repo structure.
  # See local artifacts/home.nix for the complete file.
}
