{ config, pkgs, hostname, username, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  boot.loader.systemd-boot.configurationLimit = 10;

  hardware.enableRedistributableFirmware = true;

  # Swap: compressed RAM only, no disk backing
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Prefer swapping idle pages into zram instead of dropping caches.
  boot.kernel.sysctl."vm.swappiness" = 100;

  # Networking
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # Time and locale
  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  console.keyMap = "us";
  services.xserver.xkb.layout = "us"; # niri reads this from localed

  # Input method
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
      ];
    };
  };

  # Graphics (Intel; adjust for AMD/NVIDIA)
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver # VA-API for Broadwell and newer
    vpl-gpu-rt         # oneVPL for Gen12 and newer
    libva-utils        # vainfo
  ];

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Power / device management
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.fstrim.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # Printing
  services.printing.enable = true;

  # Niri
  programs.niri.enable = true;

  # Lightweight login manager
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --cmd ${config.programs.niri.package}/bin/niri-session";
        user = "greeter";
      };
    };
  };

  services.displayManager.defaultSession = "niri";

  # Portals / dconf
  programs.dconf.enable = true;

  # User
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "render"
      "audio"
      "input"
      "bluetooth"
    ];
  };

  security.sudo.wheelNeedsPassword = true;
  security.polkit.enable = true;

  # Nix
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  nixpkgs.config.allowUnfree = true;

  # System packages (essentials; desktop apps in home-manager)
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    # Session helpers referenced by default niri config / services
    alacritty
    fuzzel
    swaylock
    waybar
    mako
    swaybg
    swayidle
    xwayland-satellite
    polkit_gnome
    gnome-keyring
    nautilus
    pavucontrol
    networkmanagerapplet
    blueman
    brightnessctl
    playerctl
    wl-clipboard
    grim
    slurp
    xdg-utils
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      dejavu_fonts
      liberation_ttf
      font-awesome
      # Maple Mono
      maple-mono.truetype
      maple-mono.NF-unhinted
      maple-mono.NF-CN-unhinted
    ];
    fontconfig.enable = true;
  };

  # Make Electron apps use Wayland natively
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # User services tied to the niri session
  systemd.user.services.mako = {
    description = "mako notification daemon";
    wantedBy = [ "niri.service" ];
    partOf = [ "niri.service" ];
    after = [ "niri.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
    };
  };

  systemd.user.services.swaybg = {
    description = "swaybg background";
    wantedBy = [ "niri.service" ];
    partOf = [ "niri.service" ];
    after = [ "niri.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -c '#1e1e2e'";
      Restart = "on-failure";
    };
  };

  systemd.user.services.swayidle = {
    description = "swayidle idle management";
    wantedBy = [ "niri.service" ];
    partOf = [ "niri.service" ];
    after = [ "niri.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${pkgs.swaylock}/bin/swaylock -f' timeout 600 '${config.programs.niri.package}/bin/niri msg action power-off-monitors' before-sleep '${pkgs.swaylock}/bin/swaylock -f'";
      Restart = "on-failure";
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome authentication agent";
    wantedBy = [ "niri.service" ];
    partOf = [ "niri.service" ];
    after = [ "niri.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };

  # State version
  system.stateVersion = "26.05";
}
