# Jose's Dotfiles

Personal dotfiles for macOS development environment setup.

## Features

- Oh My Zsh configuration with modern plugins
- Starship prompt with Catppuccin powerline theme
- Zellij terminal multiplexer with Catppuccin theme
- Neovim with LazyVim setup (auto-installed)
- Git aliases and configuration
- Development aliases for Node.js, npm, yarn
- Custom utility functions and scripts
- macOS-specific settings and optimizations
- Modern tool integrations (fzf, zoxide, eza, mise)
- Homebrew package management

## Installation

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## What's Included

- `.zshrc` - Oh My Zsh configuration with modern plugins
- `.zprofile` - Shell profile with Homebrew setup
- `.config/zellij/` - Zellij terminal multiplexer configuration
- `.gitconfig` - Git configuration and aliases
- `.ripgreprc` - ripgrep configuration
- `.macos` - macOS system preferences
- `Brewfile` - Package management with Homebrew
- `starship.toml` - Starship prompt configuration (auto-generated)
- LazyVim - Neovim configuration (auto-installed)
- Custom scripts in `.my_bin/` directory
- Font files for terminal use
- Installation and backup scripts

## Manual Setup

If you prefer manual installation:

1. Backup your existing dotfiles
2. Create symlinks:
   ```bash
   ln -sf ~/dotfiles/.zshrc ~/.zshrc
   ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
   ln -sf ~/dotfiles/.ripgreprc ~/.ripgreprc
   ```
3. Source your new shell configuration: `source ~/.zshrc`

## Customization

Personal/private configurations should go in `~/.zshrc.private` which is automatically sourced if it exists.
