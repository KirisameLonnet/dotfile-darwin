# Network Configuration (system level)
#
# Everything that touches the machine's network stack lives here. Homebrew
# options are list-merged by the module system, so the network-related
# formulae/casks declared below join the ones in ./homebrew.nix.
{ ... }:

{
  homebrew = {
    brews = [
      "ifstat" # Network interface throughput statistics
    ];

    casks = [
      # ZeroTier One installs a root launchd daemon plus a macOS system network
      # extension, so it has to come from the signed vendor pkg rather than a
      # nix package. Provides /usr/local/bin/zerotier-cli.
      "zerotier-one" # Mesh VPN client
    ];
  };
}
