#!/usr/bin/env bash
# Dotfiles installation script
# Usage: ./install.sh [--force] [--minimal] [--non-interactive] [--terminals-only]

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"

FORCE=false
MINIMAL=false
NON_INTERACTIVE=false
TERMINALS_ONLY=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --force) FORCE=true ;;
        --minimal) MINIMAL=true ;;
        --non-interactive) NON_INTERACTIVE=true ;;
        --terminals-only) TERMINALS_ONLY=true ;;
        --help)
            echo "Usage: ./install.sh [--force] [--minimal] [--non-interactive] [--terminals-only]"
            echo "  --force           Overwrite existing configs without prompting"
            echo "  --minimal         Install only shell configs (bash, zsh, starship)"
            echo "  --non-interactive Skip interactive prompts (use defaults/env vars)"
            echo "  --terminals-only  Install only terminal configs (ghostty, terminator)"
            exit 0
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_prompt() { echo -e "${CYAN}[INPUT]${NC} $*"; }

# Create backup of existing configs
backup_config() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
        log_warn "Backed up $target to $BACKUP_DIR/"
    fi
}

# Create symlink
link_config() {
    local source="$1"
    local target="$2"

    if [ -L "$target" ]; then
        local current_target=$(readlink "$target")
        if [ "$current_target" = "$source" ]; then
            log_info "Already linked: $target -> $source"
            return 0
        fi
        if [ "$FORCE" = true ]; then
            rm "$target"
        else
            log_warn "Symlink exists: $target -> $current_target (use --force to overwrite)"
            return 1
        fi
    elif [ -e "$target" ]; then
        if [ "$FORCE" = true ]; then
            backup_config "$target"
        else
            log_warn "File exists: $target (use --force to overwrite)"
            return 1
        fi
    fi

    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
    log_success "Linked $target -> $source"
}

# Prompt for Git configuration
setup_git_config() {
    local git_config_target="$CONFIG_DIR/git/config"
    local git_config_template="$DOTFILES_DIR/.config/git/config"
    
    # Skip if non-interactive
    if [ "$NON_INTERACTIVE" = true ]; then
        log_info "Non-interactive mode: linking Git config template"
        link_config "$git_config_template" "$git_config_target"
        return 0
    fi
    
    log_info "Setting up Git configuration..."
    
    # Check if git config already exists and has real values
    if [ -f "$git_config_target" ] && [ ! -L "$git_config_target" ]; then
        local existing_name=$(git config --file "$git_config_target" --get user.name 2>/dev/null || echo "")
        local existing_email=$(git config --file "$git_config_target" --get user.email 2>/dev/null || echo "")
        if [ -n "$existing_name" ] && [ "$existing_name" != "YOUR_NAME" ]; then
            log_info "Git config already exists with: $existing_name <$existing_email>"
            read -r -p "Overwrite? [y/N] " overwrite
            if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
                log_info "Keeping existing Git config"
                return 0
            fi
        fi
    fi
    
    echo
    log_prompt "=== Git Configuration ==="
    log_prompt "Enter your Git credentials (press Enter to skip/keep template)"
    echo
    
    # Get Git name
    local git_name=""
    if [ -n "${GIT_AUTHOR_NAME:-}" ]; then
        git_name="$GIT_AUTHOR_NAME"
        log_info "Using GIT_AUTHOR_NAME from environment: $git_name"
    else
        read -r -p "Git user.name: " git_name
    fi
    
    # Get Git email
    local git_email=""
    if [ -n "${GIT_AUTHOR_EMAIL:-}" ]; then
        git_email="$GIT_AUTHOR_EMAIL"
        log_info "Using GIT_AUTHOR_EMAIL from environment: $git_email"
    else
        read -r -p "Git user.email: " git_email
    fi
    
    # Get GPG key (optional)
    local git_signingkey=""
    if [ -n "${GIT_SIGNING_KEY:-}" ]; then
        git_signingkey="$GIT_SIGNING_KEY"
        log_info "Using GIT_SIGNING_KEY from environment"
    else
        read -r -p "GPG signing key (optional, press Enter to skip): " git_signingkey
    fi
    
    # Create git config directory
    mkdir -p "$(dirname "$git_config_target")"
    
    # If target is a symlink, remove it first so we write a real file
    if [ -L "$git_config_target" ]; then
        rm "$git_config_target"
    fi
    
    # Generate git config from template
    if [ -f "$git_config_template" ]; then
        # Copy template and replace placeholders
        sed \
            -e "s/YOUR_NAME/$git_name/g" \
            -e "s/YOUR_EMAIL@domain.com/$git_email/g" \
            -e "s/YOUR_GPG_KEY_ID/$git_signingkey/g" \
            "$git_config_template" > "$git_config_target"
        
        # Handle GPG signing
        if [ -n "$git_signingkey" ]; then
            sed -i 's/gpgsign = false/gpgsign = true/' "$git_config_target"
        else
            sed -i 's/gpgsign = true/gpgsign = false/' "$git_config_target"
        fi
        
        log_success "Git config written to $git_config_target"
    else
        log_warn "Git config template not found at $git_config_template"
    fi
    
    # Link gitignore (always symlink)
    link_config "$DOTFILES_DIR/.config/git/ignore" "$CONFIG_DIR/git/ignore" 2>/dev/null || true
    
    echo
}

# Install shell configurations
install_shell() {
    # If terminals-only mode, only install terminal configs
    if [ "$TERMINALS_ONLY" = true ]; then
        log_info "Installing terminal configurations only..."
        
        # Ghostty
        if [ -d "$DOTFILES_DIR/.config/ghostty" ]; then
            mkdir -p "$CONFIG_DIR/ghostty"
            for file in "$DOTFILES_DIR/.config/ghostty/"*; do
                [ -f "$file" ] && link_config "$file" "$CONFIG_DIR/ghostty/$(basename "$file")"
            done
        fi
        
        # Terminator
        if [ -d "$DOTFILES_DIR/.config/terminator" ]; then
            mkdir -p "$CONFIG_DIR/terminator"
            for file in "$DOTFILES_DIR/.config/terminator/"*; do
                [ -f "$file" ] && link_config "$file" "$CONFIG_DIR/terminator/$(basename "$file")"
            done
        fi
        
        log_success "Terminal configurations installed"
        return 0
    fi
    
    log_info "Installing shell configurations..."

    # Bash
    link_config "$DOTFILES_DIR/.config/bash/bashrc" "$HOME/.bashrc"
    link_config "$DOTFILES_DIR/.config/bash/exports.sh" "$CONFIG_DIR/bash/exports.sh"
    link_config "$DOTFILES_DIR/.config/bash/path.sh" "$CONFIG_DIR/bash/path.sh"
    link_config "$DOTFILES_DIR/.config/bash/aliases.sh" "$CONFIG_DIR/bash/aliases.sh"

    # Zsh
    link_config "$DOTFILES_DIR/.config/zsh/zshrc" "$HOME/.zshrc"

    # Starship
    mkdir -p "$CONFIG_DIR"
    link_config "$DOTFILES_DIR/.config/starship/starship.toml" "$CONFIG_DIR/starship.toml"

    # Terminal configs
    log_info "Installing terminal configurations..."
    
    # Ghostty
    if [ -d "$DOTFILES_DIR/.config/ghostty" ]; then
        mkdir -p "$CONFIG_DIR/ghostty"
        for file in "$DOTFILES_DIR/.config/ghostty/"*; do
            [ -f "$file" ] && link_config "$file" "$CONFIG_DIR/ghostty/$(basename "$file")"
        done
    fi
    
    # Terminator
    if [ -d "$DOTFILES_DIR/.config/terminator" ]; then
        mkdir -p "$CONFIG_DIR/terminator"
        for file in "$DOTFILES_DIR/.config/terminator/"*; do
            [ -f "$file" ] && link_config "$file" "$CONFIG_DIR/terminator/$(basename "$file")"
        done
    fi

    # Git (interactive)
    setup_git_config

    log_success "Shell configurations installed"
}

# Install nvim configuration
install_nvim() {
    if [ "$MINIMAL" = true ]; then
        log_info "Skipping nvim (minimal mode)"
        return 0
    fi

    log_info "Installing nvim configuration..."

    link_config "$DOTFILES_DIR/.config/nvim/init.lua" "$CONFIG_DIR/nvim/init.lua"

    # Link all lua config files
    for file in "$DOTFILES_DIR/.config/nvim/lua"/**/*.lua; do
        if [ -f "$file" ]; then
            local rel_path="${file#$DOTFILES_DIR/.config/nvim/}"
            link_config "$file" "$CONFIG_DIR/nvim/$rel_path"
        fi
    done

    log_success "Nvim configuration installed"
}

# Install micro editor config
install_micro() {
    if [ "$MINIMAL" = true ]; then
        return 0
    fi

    log_info "Installing micro editor configuration..."
    mkdir -p "$CONFIG_DIR/micro"
    link_config "$DOTFILES_DIR/.config/micro/settings.json" "$CONFIG_DIR/micro/settings.json" 2>/dev/null || true
    link_config "$DOTFILES_DIR/.config/micro/bindings.json" "$CONFIG_DIR/micro/bindings.json" 2>/dev/null || true
}

# Install scripts
install_scripts() {
    log_info "Installing scripts..."

    mkdir -p "$HOME/scripts"
    if [ -d "$DOTFILES_DIR/scripts" ]; then
        cp -r "$DOTFILES_DIR/scripts/"* "$HOME/scripts/" 2>/dev/null || true
        chmod +x "$HOME/scripts/"**/* 2>/dev/null || true
    fi

    log_success "Scripts installed"
}

# Initialize git submodules and install wallpapers
install_wallpapers() {
    log_info "Initializing git submodules..."

    cd "$DOTFILES_DIR"
    git submodule update --init --recursive 2>/dev/null || true

    # Install wallpapers if submodule exists
    local wallpaper_src="$DOTFILES_DIR/wallpaper"
    local wallpaper_dst="$HOME/Pictures/Wallpapers"

    if [ -d "$wallpaper_src" ] && [ "$(ls -A "$wallpaper_src" 2>/dev/null | grep -v '^\.git$')" ]; then
        log_info "Installing wallpapers to $wallpaper_dst..."
        mkdir -p "$wallpaper_dst"
        cp -r "$wallpaper_src/"* "$wallpaper_dst/" 2>/dev/null || true
        log_success "Wallpapers installed to $wallpaper_dst"
    else
        log_warn "Wallpaper submodule not found or empty at $wallpaper_src"
    fi
}

# Install system packages (optional)
install_packages() {
    if [ "$MINIMAL" = true ]; then
        return 0
    fi

    if ! command -v pacman &>/dev/null && ! command -v apt &>/dev/null && ! command -v dnf &>/dev/null && ! command -v brew &>/dev/null; then
        log_warn "No supported package manager found, skipping package installation"
        return 0
    fi

    log_info "Installing recommended packages..."

    local packages=(
        "zsh" "git" "curl" "wget" "unzip"
        "neovim" "starship" "zoxide" "fzf" "eza" "bat" "fd" "ripgrep"
        "trash-cli" "# fastfetch" "thefuck" "direnv" "atuin"
        "lazygit" "docker" "go" "rust" "nodejs" "python3" "python3-pip" "pipx"
    )

    if command -v pacman &>/dev/null; then
        sudo pacman -S --needed --noconfirm "${packages[@]}" 2>/dev/null || true
    elif command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y "${packages[@]}" 2>/dev/null || true
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "${packages[@]}" 2>/dev/null || true
    elif command -v brew &>/dev/null; then
        brew install "${packages[@]}" 2>/dev/null || true
    fi

    # Install oh-my-zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Install zsh plugins
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    [ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ] && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
    [ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ] && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/plugins/zsh-syntax-highlighting"
    [ ! -d "$zsh_custom/plugins/fzf-tab" ] && git clone --depth=1 https://github.com/Aloxaf/fzf-tab "$zsh_custom/plugins/fzf-tab"

    log_success "Packages installed"
}

# Set zsh as default shell
set_zsh_shell() {
    if [ "$SHELL" != "$(which zsh)" ] && command -v zsh &>/dev/null; then
        log_info "Setting zsh as default shell..."
        chsh -s "$(which zsh)" && log_success "Default shell changed to zsh"
    fi
}

# Main installation
main() {
    log_info "Starting dotfiles installation from $DOTFILES_DIR"

    # Create config directory
    mkdir -p "$CONFIG_DIR"

    if [ "$TERMINALS_ONLY" = true ]; then
        install_shell
        log_success "Terminal configurations installed!"
        return 0
    fi

    install_shell
    install_nvim
    install_micro
    install_scripts
    install_wallpapers

    if [ "$MINIMAL" != true ]; then
        install_packages
        set_zsh_shell
    fi

    log_success "Installation complete!"
    log_info "Restart your shell or run 'source ~/.zshrc' (or ~/.bashrc) to apply changes"

    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
        log_info "Backups saved to: $BACKUP_DIR"
    fi
    
    echo
    log_info "=== Next Steps ==="
    echo "  1. Restart terminal or run: source ~/.zshrc"
    echo "  2. Open nvim to auto-install plugins: nvim"
    echo "  3. Verify Git config: git config --list --show-origin"
    echo "  4. For GPG signing: gpg --list-secret-keys --keyid-format=long"
}

main "$@"