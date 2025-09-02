## Nixos Configuration

### First Boot checklist:

- configure git
  - `gh auth login`
  - `ssh-keygen`
  - update github SSH keys
  - `git config --global` for `user.name` and `user.email`
- enroll into tailscale
- configure KDE
  - go through `system/plasma.nix`
- configure chrome
  - default browser
  - disable telemetry
  - sign-in
  - enable sync
  - bitwarden login and set PIN
  - 2FAS login
