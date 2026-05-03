# Arch Linux Reinstall Workflow

This guide is for an LLM agent rebuilding this exact dotfiles setup on a fresh Arch Linux machine. Follow it in order, verify after each stage, and stop on errors instead of guessing.

Filename note: this repo uses `ARCH-LINUX-REINSTALL.md` (hyphens), not `ARCH_LINUX_REINSTALL.md`.

## Managed configs

Stow targets in this repo:

- `zsh` -> `~/.zshrc`, `~/.zprofile`
- `nvim` -> `~/.config/nvim` (Git submodule: `kickstart.nvim`)
- `alacritty` -> `~/.config/alacritty/alacritty.toml`
- `vim` -> `~/.vimrc`
- `x` -> `~/.xinitrc`, `~/.xprofile`
- `i3` -> `~/.config/i3`, `~/.config/i3status`
- `picom` -> `~/.config/picom`
- `polybar` -> `~/.config/polybar`
- `dunst` -> `~/.config/dunst`
- `fonts` -> `~/.local/share/fonts`

Do not stow only `zsh nvim alacritty vim x`; that misses active configs.

## 0. Pre-flight

```bash
set -euo pipefail
whoami
pwd
uname -a
pacman --version
```

If this is not Arch Linux, stop and ask the user.

## 1. Bootstrap packages before yay

`yay` cannot install itself. Install build requirements first:

```bash
sudo pacman -Syu --needed \
  base-devel git openssh ca-certificates \
  zsh vim neovim curl wget stow fontconfig
```

## 2. GitHub SSH access

The dotfiles repo and `nvim/.config/nvim` submodule use SSH URLs. Configure SSH before cloning, otherwise submodule clone may fail with `Host key verification failed`.

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts
chmod 644 ~/.ssh/known_hosts

if [ ! -f ~/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -C "music0227@gmail.com"
  echo "Add ~/.ssh/id_ed25519.pub to GitHub, then rerun: ssh -T git@github.com"
  exit 1
fi

cat > ~/.ssh/config <<'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
EOF
chmod 600 ~/.ssh/config

ssh -T git@github.com || true
```

If GitHub authentication fails, stop and ask the user to add the public key. Do not switch to token URLs unless the user provides a token.

## 3. Clone repos and initialize submodules

```bash
git clone --recurse-submodules git@github.com:Michael-Kao/dotfiles.git ~/dotfiles
git clone git@github.com:Michael-Kao/vault.git ~/vault

cd ~/dotfiles
git submodule sync --recursive
git submodule update --init --recursive
git submodule status --recursive
```

Expected: `git submodule status` should not start with `-`. A leading `-` means the submodule is registered but not cloned.

Private-repo rule: `dotfiles`, `vault`, and `kickstart.nvim` must use SSH remotes. Do not replace them with `https://github.com/...` URLs. If SSH fails, fix the SSH key/known_hosts/GitHub access and retry.

```bash
git remote set-url origin git@github.com:Michael-Kao/dotfiles.git
git config submodule.nvim/.config/nvim.url git@github.com:Michael-Kao/kickstart.nvim.git
git submodule sync --recursive
git submodule update --init --recursive

if [ -d ~/vault/.git ]; then
  git -C ~/vault remote set-url origin git@github.com:Michael-Kao/vault.git
fi
```

## 4. Install yay

```bash
mkdir -p ~/build-tools
cd ~/build-tools
if [ ! -d yay ]; then
  git clone https://aur.archlinux.org/yay.git
fi
cd yay
git pull --ff-only || true
makepkg -si --needed
yay --version
```

## 5. Install packages

Install in groups so errors are easy to identify.

### Core CLI/dev tools

```bash
yay -S --needed \
  git openssh zsh vim neovim curl wget \
  python python-pip nodejs npm rust cargo go \
  htop fzf ripgrep stow lazygit fontconfig
```

`neofetch` is optional/unmaintained; do not fail the reinstall if it is unavailable.

### Terminal and fonts

```bash
yay -S --needed \
  alacritty kitty \
  ttf-firacode-nerd ttf-jetbrains-mono-nerd
```

This repo also includes bundled Nerd Fonts under `fonts/.local/share/fonts`; stowing `fonts` plus `fc-cache` is enough if AUR font names change.

### X11/i3 stack used by this repo

The checked-in desktop configs are primarily X11/i3-related:

```bash
yay -S --needed \
  xorg-xinit i3-wm i3status dmenu \
  picom polybar dunst \
  dex xss-lock i3lock network-manager-applet \
  libpulse pipewire pipewire-pulse \
  fcitx5 fcitx5-configtool
```

Notes:

- `i3/.config/i3/config` references `dmenu_run`, `i3status`, `xss-lock`, `i3lock`, `nm-applet`, `pactl`, and `dex`.
- `x/.xinitrc` currently has `exec i3` commented out. Uncomment it if using `startx` to launch i3.

### Optional Wayland/Sway stack

No Sway config is currently stored in this repo. Install this only if the user wants Sway:

```bash
yay -S --needed \
  sway swaybg swayidle swaylock waybar bemenu mako \
  wl-clipboard wofi kanshi grim slurp pamixer playerctl
```

### Applications

```bash
yay -S --needed firefox spotify discord bitwarden obsidian
```

If an AUR app fails, continue with dotfiles setup and report the failed package.

## 6. Stow dotfiles safely

Always dry-run first from the repo root:

```bash
cd ~/dotfiles
STOW_TARGETS="zsh nvim alacritty vim x i3 picom polybar dunst fonts"
stow --simulate --verbose $STOW_TARGETS
```

If dry-run reports conflicts, back up existing real files before stowing:

```bash
mkdir -p ~/dotfiles-backup
for p in \
  ~/.zshrc ~/.zprofile ~/.vimrc ~/.xinitrc ~/.xprofile \
  ~/.config/nvim ~/.config/alacritty ~/.config/i3 ~/.config/i3status \
  ~/.config/picom ~/.config/polybar ~/.config/dunst \
  ~/.local/share/fonts; do
  if [ -e "$p" ] && [ ! -L "$p" ]; then
    mv "$p" ~/dotfiles-backup/
  fi
done
```

Then create/update symlinks:

```bash
cd ~/dotfiles
stow --restow --verbose $STOW_TARGETS
```

## 7. Verify installation

### Symlinks

```bash
for p in \
  ~/.zshrc ~/.zprofile ~/.vimrc ~/.xinitrc ~/.xprofile \
  ~/.config/nvim ~/.config/alacritty ~/.config/i3 ~/.config/i3status \
  ~/.config/picom ~/.config/polybar ~/.config/dunst \
  ~/.local/share/fonts; do
  if [ -L "$p" ]; then
    printf 'OK symlink: %s -> %s\n' "$p" "$(readlink "$p")"
  else
    printf 'MISSING or not symlink: %s\n' "$p"
  fi
done
```

Do not use `ls -la ~ | grep '^l'` as the only verification; it misses symlinks under `~/.config` and `~/.local`.

### Commands

```bash
for c in git zsh vim nvim alacritty stow fc-cache fc-list yay; do
  command -v "$c" >/dev/null && echo "OK $c" || echo "MISSING $c"
done

for c in i3 i3status dmenu_run picom polybar dunst xss-lock i3lock nm-applet pactl dex; do
  command -v "$c" >/dev/null && echo "OK $c" || echo "MISSING $c"
done
```

### Config checks

```bash
cd ~/dotfiles
git submodule status --recursive

zsh -n zsh/.zshrc
zsh -n zsh/.zprofile
vim --clean --not-a-term -Nu vim/.vimrc -n -es -c 'q'
nvim --headless '+Lazy! sync' '+qa'
nvim --headless '+quit'

fc-cache -fv ~/.local/share/fonts
fc-list | grep -Ei 'FiraCode|JetBrains'
```

Alacritty has no pure config-check command. A short startup is acceptable; VM/remote graphics warnings are not dotfile failures if Alacritty reports the config file loaded:

```bash
timeout 3 alacritty --config-file ~/.config/alacritty/alacritty.toml --print-events || true
```

i3 config validation requires `i3` to be installed:

```bash
i3 -C -c ~/.config/i3/config
```

## 8. Post-install user settings

```bash
git config --global user.name "kao"
git config --global user.email "music0227@gmail.com"
git config --global init.defaultBranch main

chsh -s "$(command -v zsh)" "$USER"
```

Install Pure prompt if missing:

```bash
if [ ! -d ~/.zsh/pure ]; then
  mkdir -p ~/.zsh
  git clone https://github.com/sindresorhus/pure ~/.zsh/pure
fi
```

## 9. Vault reconstruction

If `~/vault` was not cloned earlier:

```bash
git clone git@github.com:Michael-Kao/vault.git ~/vault
```

In Obsidian: Open vault -> select `~/vault`.

## 10. Known verification issues fixed in this guide

- Old guide used the wrong filename spelling (`ARCH_LINUX_REINSTALL.md`).
- Old guide stowed only five targets and missed `i3`, `picom`, `polybar`, `dunst`, and `fonts`.
- `nvim` is a submodule; when SSH/known_hosts is not ready, it remains empty and `git submodule status` starts with `-`.
- Old guide emphasized Sway, but this repo contains X11/i3 configs and no Sway config.
- `chsh -s /bin/zsh kao` was hard-coded. Use the current user and `command -v zsh`.
- Token-style `git remote set-url origin https://Michael-Kao@github.com/...` is not a reliable SSH fix.
- `zsh/.zshrc` had `export PATH="$PATH:$/home/kao/.cargo/bin"`; the extra `$` prevented the intended Cargo path from being added. It is now `export PATH="$PATH:$HOME/.cargo/bin"`.
- Neovim verification exposed an `nvim-treesitter.configs` startup error when `nvim-treesitter` was pulled from its newer `main` branch. The local fix is to pin `nvim-treesitter` to `branch = 'master'` in `nvim/.config/nvim/lua/kickstart/plugins/treesitter.lua`, then run `nvim --headless '+Lazy! sync' '+qa'` and retry startup.

## References

- [Arch Wiki](https://wiki.archlinux.org)
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [i3 User Guide](https://i3wm.org/docs/userguide.html)
- [Sway Wiki](https://github.com/swaywm/sway/wiki)
