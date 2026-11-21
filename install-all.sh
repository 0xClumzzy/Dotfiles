#!/usr/bin/env bash
# Universal Dotfiles Installer
# Interactive menu to select and install components

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_prompt() { echo -e "${CYAN}[SELECT]${NC} $*"; }
log_header() { echo -e "${BOLD}${MAGENTA}$*${NC}"; }

# Component definitions
COMPONENTS=(
    "dotfiles|Dotfiles (bash, zsh, starship, git, nvim, micro)|./install.sh"
    "fonts|Nerd Fonts (with icursive cursive variants)|./scripts/install-fonts.sh"
    "sync|Auto-Sync Daemon (systemd, monthly push)|./scripts/install-sync.sh"
)

# Check if component is already installed
check_installed() {
    local component="$1"
    case "$component" in
        dotfiles)
            [ -L "$HOME/.bashrc" ] && [ -L "$HOME/.zshrc" ] && [ -L "$HOME/.config/starship.toml" ]
            ;;
        fonts)
            fc-list | grep -qi -e "nerd" -e "icursive" && return 0 || return 1
            ;;
        sync)
            systemctl --user is-enabled dotfiles-sync.service &>/dev/null && return 0 || return 1
            ;;
    esac
}

# Show component status
show_status() {
    echo -e "\n${BOLD}=== Component Status ===${NC}"
    local i=1
    for comp in "${COMPONENTS[@]}"; do
        IFS='|' read -r name desc script <<< "$comp"
        local status="❌ Not installed"
        # Debug
        if check_installed "$name"; then
            status="✅ Installed"
        fi
        echo -e "  ${CYAN}$i)${NC} $desc"
        echo -e "      $status"
        ((i++))
    done
    echo
}

# Install component
install_component() {
    local component="$1"
    local script="$2"
    
    log_info "Installing $component..."
    
    if [ -f "$SCRIPTS_DIR/$script" ] || [ -f "$DOTFILES_DIR/$script" ]; then
        local script_path="$SCRIPTS_DIR/$script"
        [ -f "$DOTFILES_DIR/$script" ] && script_path="$DOTFILES_DIR/$script"
        
        if bash "$script_path" "${@:3}"; then
            log_success "$component installed successfully"
            return 0
        else
            log_error "$component installation failed"
            return 1
        fi
    else
        log_error "Script not found: $script"
        return 1
    fi
}

# Interactive menu
interactive_menu() {
    while true; do
        clear
        log_header "╔══════════════════════════════════════════════════════════╗"
        log_header "║           Universal Dotfiles Installer                     ║"
        log_header "╚══════════════════════════════════════════════════════════╝"
        echo
        
        show_status
        
        echo -e "${BOLD}Options:${NC}"
        echo -e "  ${CYAN}1-${#COMPONENTS[@]})${NC} Install/Reinstall component"
        echo -e "  ${CYAN}a)${NC} Install ALL components"
        echo -e "  ${CYAN}u)${NC} Update fonts to latest"
        echo -e "  ${CYAN}s)${NC} Show detailed status"
        echo -e "  ${CYAN}q)${NC} Quit"
        echo
        
        log_prompt "Select option: "
        read -r choice
        
        case "$choice" in
            [1-9])
                if [ "$choice" -ge 1 ] && [ "$choice" -le ${#COMPONENTS[@]} ]; then
                    local idx=$((choice - 1))
                    IFS='|' read -r name desc script <<< "${COMPONENTS[$idx]}"
                    
                    echo
                    log_info "Installing: $desc"
                    
                    case "$name" in
                        dotfiles)
                            read -r -p "Install mode? [minimal/full/force] (default: full): " mode
                            mode="${mode:-full}"
                            case "$mode" in
                                minimal) install_component "$name" "$script" --minimal ;;
                                force) install_component "$name" "$script" --force ;;
                                *) install_component "$name" "$script" ;;
                            esac
                            ;;
                        fonts)
                            echo "Font install mode:"
                            echo "  1) Interactive selector"
                            echo "  2) Install icursive only (cursive)"
                            echo "  3) Install specific fonts (comma-separated)"
                            read -r -p "Choose [1-3] (default: 1): " font_mode
                            font_mode="${font_mode:-1}"
                            case "$font_mode" in
                                1) install_component "$name" "$script" ;;
                                2) install_component "$name" "$script" -i 0 ;;
                                3) read -r -p "Font numbers (e.g., 1,3,5): " nums
                                   install_component "$name" "$script" -i "$nums" ;;
                            esac
                            ;;
                        sync)
                            install_component "$name" "$script"
                            ;;
                    esac
                    
                    echo
                    read -r -p "Press Enter to continue..."
                else
                    log_error "Invalid choice"
                    sleep 1
                fi
                ;;
            a|A)
                log_info "Installing ALL components..."
                for comp in "${COMPONENTS[@]}"; do
                    IFS='|' read -r name desc script <<< "$comp"
                    install_component "$name" "$script" || true
                done
                log_success "All components processed"
                read -r -p "Press Enter to continue..."
                ;;
            u|U)
                log_info "Updating fonts..."
                "$SCRIPTS_DIR/install-fonts.sh" -u
                read -r -p "Press Enter to continue..."
                ;;
            s|S)
                show_detailed_status
                read -r -p "Press Enter to continue..."
                ;;
            q|Q)
                log_info "Goodbye!"
                exit 0
                ;;
            *)
                log_error "Invalid option"
                sleep 1
                ;;
        esac
    done
}

show_detailed_status() {
    clear
    log_header "=== Detailed Status ==="
    echo
    
    # Dotfiles
    echo -e "${BOLD}Dotfiles:${NC}"
    for file in .bashrc .zshrc .config/starship.toml .config/git/config; do
        if [ -L "$HOME/$file" ]; then
            echo -e "  ✅ $file -> $(readlink $HOME/$file)"
        elif [ -f "$HOME/$file" ]; then
            echo -e "  ⚠️  $file (file, not symlink)"
        else
            echo -e "  ❌ $file (missing)"
        fi
    done
    echo
    
    # Fonts
    echo -e "${BOLD}Fonts:${NC}"
    fc-list | grep -i "nerd" | sed -E 's/^[^:]+: ([^,]+)(,.*)?$/\1/' | cut -d: -f1 | sort -u | grep -v '^$' | grep -v ':style=' | while read -r font; do
        echo -e "  ✅ $font"
    done
    echo
    
    # Sync
    echo -e "${BOLD}Auto-Sync:${NC}"
    if systemctl --user is-enabled dotfiles-sync.service &>/dev/null; then
        echo -e "  ✅ Service enabled"
        systemctl --user status dotfiles-sync.service --no-pager | head -5
    else
        echo -e "  ❌ Not installed"
    fi
    echo
    
    # Systemd timers
    echo -e "${BOLD}Timers:${NC}"
    systemctl --user list-timers dotfiles-sync.timer --no-pager 2>/dev/null || echo "  No timers"
}

# Parse arguments
parse_args() {
    case "${1:-}" in
        --all)
            for comp in "${COMPONENTS[@]}"; do
                IFS='|' read -r name desc script <<< "$comp"
                install_component "$name" "$script" "${@:2}"
            done
            ;;
        --dotfiles)
            install_component "dotfiles" "install.sh" "${@:2}"
            ;;
        --fonts)
            install_component "fonts" "scripts/install-fonts.sh" "${@:2}"
            ;;
        --sync)
            install_component "sync" "scripts/install-sync.sh" "${@:2}"
            ;;
        --status)
            show_detailed_status
            ;;
        --help|-h|"")
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

show_help() {
    echo "Usage: $0 [option]"
    echo
    echo "Options:"
    echo "  (no args)       Interactive menu"
    echo "  --all           Install all components"
    echo "  --dotfiles      Install dotfiles only"
    echo "  --fonts         Install fonts only"
    echo "  --sync          Install sync daemon only"
    echo "  --status        Show detailed status"
    echo "  --help          Show this help"
    echo
    echo "Examples:"
    echo "  $0                    # Interactive menu"
    echo "  $0 --all              # Install everything"
    echo "  $0 --dotfiles --minimal  # Minimal dotfiles install"
    echo "  $0 --fonts -i 0       # Install icursive only"
}

# Main
main() {
    # Make scripts executable
    chmod +x "$DOTFILES_DIR/install.sh" 2>/dev/null || true
    chmod +x "$SCRIPTS_DIR/install-fonts.sh" 2>/dev/null || true
    chmod +x "$SCRIPTS_DIR/install-sync.sh" 2>/dev/null || true
    chmod +x "$SCRIPTS_DIR/sync-dotfiles.sh" 2>/dev/null || true
    
    if [ $# -eq 0 ]; then
        interactive_menu
    else
        parse_args "$@"
    fi
}

main "$@"