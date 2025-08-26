#!/bin/bash

# Backup script for existing dotfiles
# Run this before installing new dotfiles to preserve your current setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo -e "${GREEN}📦 Creating backup of existing dotfiles${NC}"
echo "Backup directory: $BACKUP_DIR"
echo

# Create backup directory
mkdir -p "$BACKUP_DIR"

# List of files to backup
files=(
    ".zshrc"
    ".bashrc"
    ".bash_profile"
    ".gitconfig"
    ".gitignore_global"
    ".ripgreprc"
    ".tmux.conf"
    ".ssh/config"
)

# Backup files if they exist
for file in "${files[@]}"; do
    if [ -f "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
        echo -e "${YELLOW}📄 Backing up $file${NC}"
        
        # Create directory structure in backup
        backup_file="$BACKUP_DIR/$file"
        backup_dir=$(dirname "$backup_file")
        mkdir -p "$backup_dir"
        
        # Copy the file
        cp -L "$HOME/$file" "$backup_file" 2>/dev/null || cp "$HOME/$file" "$backup_file"
    fi
done

# Backup directories
dirs=(
    ".ssh"
    ".vim"
    ".my_bin"
    ".config/nvim"
    ".oh-my-zsh"
)

for dir in "${dirs[@]}"; do
    if [ -d "$HOME/$dir" ]; then
        echo -e "${YELLOW}📁 Backing up $dir/${NC}"
        cp -r "$HOME/$dir" "$BACKUP_DIR/"
    fi
done

# Generate restoration script
cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash
# Restoration script for backed up dotfiles
# Run this script to restore your backed up dotfiles

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Restoring dotfiles from backup..."

# Restore files
find "$BACKUP_DIR" -type f -name ".*" | while read -r file; do
    relative_path="${file#$BACKUP_DIR/}"
    target_path="$HOME/$relative_path"
    target_dir=$(dirname "$target_path")
    
    echo "Restoring $relative_path"
    mkdir -p "$target_dir"
    cp "$file" "$target_path"
done

echo "Backup restoration complete!"
EOF

chmod +x "$BACKUP_DIR/restore.sh"

echo
echo -e "${GREEN}✅ Backup complete!${NC}"
echo -e "${YELLOW}📋 Backup location: $BACKUP_DIR${NC}"
echo -e "${YELLOW}📋 To restore: $BACKUP_DIR/restore.sh${NC}"
echo
