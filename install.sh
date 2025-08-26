#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo -e "${GREEN}🚀 Jose's Dotfiles Installation${NC}"
echo "Installing dotfiles from: $DOTFILES_DIR"
echo

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}🚀 Installing Oh My Zsh${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo -e "${GREEN}✅ Oh My Zsh installed${NC}"
else
    echo -e "${YELLOW}ℹ️  Oh My Zsh already installed${NC}"
fi

# Install Oh My Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo -e "${GREEN}💡 Installing zsh-autosuggestions plugin${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Install zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo -e "${GREEN}🌈 Installing zsh-syntax-highlighting plugin${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
echo

# Function to backup existing files
backup_if_exists() {
    if [ -f "$1" ] || [ -L "$1" ]; then
        echo -e "${YELLOW}📦 Backing up existing $1 to $1.backup${NC}"
        mv "$1" "$1.backup"
    fi
}

# Function to validate symlink
validate_symlink() {
    local link="$1"
    if [[ -L "$link" ]] && [[ ! -e "$link" ]]; then
        echo -e "${RED}❌ Broken symlink detected: $link${NC}"
        return 1
    elif [[ -L "$link" ]] && [[ -e "$link" ]]; then
        echo -e "${GREEN}✅ Valid symlink: $link -> $(readlink "$link")${NC}"
        return 0
    elif [[ -f "$link" ]]; then
        echo -e "${YELLOW}📄 Regular file (not symlink): $link${NC}"
        return 0
    else
        echo -e "${RED}❌ Missing file: $link${NC}"
        return 1
    fi
}

# Function to create symlink with validation
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ ! -f "$source" ]; then
        echo -e "${RED}❌ Source file not found: $source${NC}"
        return 1
    fi
    
    # Make source path absolute for more reliable symlinks
    source=$(realpath "$source")
    
    backup_if_exists "$target"
    echo -e "${GREEN}🔗 Linking $source -> $target${NC}"
    
    if ln -sf "$source" "$target"; then
        # Validate the symlink was created correctly
        if validate_symlink "$target" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Symlink created successfully${NC}"
            return 0
        else
            echo -e "${RED}❌ Symlink validation failed${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Failed to create symlink${NC}"
        return 1
    fi
}

# Create symlinks for dotfiles
echo -e "${GREEN}📂 Creating symlinks...${NC}"

create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
create_symlink "$DOTFILES_DIR/.ripgreprc" "$HOME/.ripgreprc"

# Create .my_bin directory symlink
if [ -d "$DOTFILES_DIR/.my_bin" ]; then
    backup_if_exists "$HOME/.my_bin"
    echo -e "${GREEN}🔗 Linking $DOTFILES_DIR/.my_bin -> $HOME/.my_bin${NC}"
    ln -sf "$DOTFILES_DIR/.my_bin" "$HOME/.my_bin"
fi

# Create .config directory and symlinks
if [ -d "$DOTFILES_DIR/.config" ]; then
    mkdir -p "$HOME/.config"
    # Link Zellij config
    if [ -d "$DOTFILES_DIR/.config/zellij" ]; then
        backup_if_exists "$HOME/.config/zellij"
        echo -e "${GREEN}🔗 Linking $DOTFILES_DIR/.config/zellij -> $HOME/.config/zellij${NC}"
        ln -sf "$DOTFILES_DIR/.config/zellij" "$HOME/.config/zellij"
    fi
fi

# Create .zshrc.private if it doesn't exist
if [ ! -f "$HOME/.zshrc.private" ]; then
    echo -e "${YELLOW}📝 Creating ~/.zshrc.private for personal configurations${NC}"
    cat > "$HOME/.zshrc.private" << 'EOF'
# Personal/private zsh configurations
# This file is sourced by .zshrc and should contain:
# - Personal aliases
# - API keys and secrets (use environment variables)
# - Machine-specific configurations
# - Work-related configurations

# Example:
# export GITHUB_TOKEN="your_token_here"
# alias work="cd ~/work && code ."

echo "🏠 Loaded private zsh configuration"
EOF
fi

# Setup Starship configuration if starship is installed
if command -v starship &> /dev/null; then
    echo -e "${GREEN}🚀 Setting up Starship with Catppuccin powerline preset${NC}"
    mkdir -p "$HOME/.config"
    starship preset catppuccin-powerline -o "$HOME/.config/starship.toml"
    echo -e "${GREEN}✅ Starship configuration created${NC}"
else
    echo -e "${YELLOW}⚠️  Starship not found. Install with: brew install starship${NC}"
    echo -e "${YELLOW}    Then run: starship preset catppuccin-powerline -o ~/.config/starship.toml${NC}"
fi

# Setup LazyVim if neovim is installed
if command -v nvim &> /dev/null; then
    if [ ! -d "$HOME/.config/nvim" ]; then
        echo -e "${GREEN}⚡ Installing LazyVim${NC}"
        # Backup existing nvim config if it exists
        if [ -d "$HOME/.config/nvim" ]; then
            echo -e "${YELLOW}📦 Backing up existing nvim config${NC}"
            mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup"
        fi
        
        # Clone LazyVim starter
        git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
        
        # Remove .git folder from the starter template
        rm -rf "$HOME/.config/nvim/.git"
        
        echo -e "${GREEN}✅ LazyVim installed! Run 'nvim' to complete setup${NC}"
    else
        echo -e "${YELLOW}ℹ️  Neovim config already exists at ~/.config/nvim${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Neovim not found. Install with: brew install neovim${NC}"
    echo -e "${YELLOW}    Then run this script again to install LazyVim${NC}"
fi

# Final validation of all symlinks
echo
echo -e "${GREEN}🔍 Final symlink validation...${NC}"
SYMLINKS=("$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.gitconfig" "$HOME/.gitignore_global" "$HOME/.ripgreprc")
VALIDATION_FAILED=0

for link in "${SYMLINKS[@]}"; do
    if ! validate_symlink "$link" >/dev/null 2>&1; then
        VALIDATION_FAILED=1
    fi
done

if [ $VALIDATION_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All symlinks validated successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  Some symlinks failed validation. Check output above.${NC}"
fi

echo
echo -e "${GREEN}✅ Dotfiles installation complete!${NC}"
echo
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Edit ~/.zshrc.private for personal configurations"
echo "  3. Update git user info in ~/.gitconfig if needed"
echo "  4. Install required tools:"
echo "     - brew install ripgrep delta hub"
echo "     - Install a Nerd Font for better terminal experience"
echo "  5. Run 'dotfiles-health' anytime to check symlink health"
echo
echo -e "${GREEN}🎉 Happy coding!${NC}"
