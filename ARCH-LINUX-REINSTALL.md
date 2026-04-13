# Arch Linux Reinstall Workflow

This document is for AI Agent to rebuild your workflow on a fresh Arch Linux environment.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Package Installation](#package-installation)
- [Dotfiles Reconstruction](#dotfiles-reconstruction)
- [Vault Reconstruction](#vault-reconstruction)
- [Post-Installation](#post-installation)

---

## Prerequisites

### GitHub Repositories

Ensure the following repositories are accessible:

- **dotfiles**: `git@github.com:Michael-Kao/dotfiles.git`
- **vault**: `git@github.com:Michael-Kao/vault.git`
- **kickstart.nvim**: `git@github.com:Michael-Kao/kickstart.nvim.git` (submodule)

### SSH Key (if needed)

```bash
ssh-keygen -t ed25519 -C "music0227@gmail.com"
# Add public key to GitHub
```

---

## Package Installation

All packages should be installed via yay (AUR helper).

### 1. Install Yay (AUR Helper) First

```bash
mkdir -p ~/build-tools
cd ~/build-tools
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### 2. Core Packages

```bash
yay -S \
  git zsh vim curl wget \
  python python-pip \
  nodejs npm \
  rust cargo go \
  htop neofetch fzf ripgrep \
  stow
```

### 3. Wayland / Sway

```bash
yay -S \
  sway swaybg swayidle swaylock \
  waybar bemenu mako \
  wl-clipboard wofi \
  kanshi grim slurp \
  pamixer playerctl
```

### 4. Terminal & Editor

```bash
yay -S \
  alacritty kitty \
  neovim lazygit
```

### 5. Applications

```bash
yay -S \
  spotify discord \
  bitwarden obsidian \
  firefox
```

### 6. Fonts

```bash
yay -S \
  ttf-firacode-nerd ttf-jetbrainsmono-nerd
```

---

## Dotfiles Reconstruction

### 1. Clone Repositories

```bash
git clone --recurse-submodules git@github.com:Michael-Kao/dotfiles.git ~/dotfiles
git clone git@github.com:Michael-Kao/vault.git ~/vault
```

### 2. Use Stow to Create Symlinks

```bash
cd ~/dotfiles

# Create all config symlinks
stow zsh nvim alacritty vim x

# Or individually
stow zsh
stow nvim
stow alacritty
stow vim
stow x
```

### 3. Verify Symlinks

```bash
ls -la ~ | grep "^l"
# Expected:
# .zshrc -> dotfiles/zsh/.zshrc
# .config/nvim -> dotfiles/nvim/.config/nvim
# .config/alacritty -> dotfiles/alacritty/.config/alacritty
```

---

## Vault Reconstruction

Vault is already on GitHub, simply clone back:

```bash
git clone git@github.com:Michael-Kao/vault.git ~/vault
```

To use with Obsidian:
1. Install Obsidian
2. Open Obsidian → Open vault → Select `~/vault`

---

## Post-Installation

### Git Config

```bash
git config --global user.name "kao"
git config --global user.email "music0227@gmail.com"
git config --global init.defaultBranch main
```

### SSH Config

Edit `~/.ssh/config`:

```bash
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
```

### Zsh Setup

```bash
chsh -s /bin/zsh kao

# Install pure prompt
mkdir -p ~/.zsh/pure
git clone https://github.com/sindresorhus/pure ~/.zsh/pure
```

### Start Sway

```bash
# First time
exec sway
```

---

## Troubleshooting

### Q: Submodule not cloned completely

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

### Q: No permission to push

```bash
# Check SSH key
ssh -T git@github.com

# Or use token
git remote set-url origin https://Michael-Kao@github.com/Michael-Kao/dotfiles.git
```

### Q: Font not displayed correctly

```bash
fc-cache -fv
# Verify fontconfig
fc-list | grep -i nerd
```

---

## References

- [Arch Wiki](https://wiki.archlinux.org)
- [Sway Wiki](https://github.com/swaywm/sway/wiki)
- [Stow Manual](https://www.gnu.org/software/stow/manual/)