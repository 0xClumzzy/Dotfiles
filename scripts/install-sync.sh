#!/usr/bin/env bash
# Install dotfiles sync daemon (systemd user service)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-/home/clumzzy/Projects/Dotfiles}"
SYNC_SCRIPT="$SCRIPT_DIR/sync-dotfiles.sh"
SERVICE_FILE="$SCRIPT_DIR/dotfiles-sync.service"
TIMER_FILE="$SCRIPT_DIR/dotfiles-sync.timer"

SERVICE_DIR="$HOME/.config/systemd/user"
LOG_DIR="$HOME/.local/state"

log_info() { echo -e "\033[0;34m[INFO]\033[0m $*"; }
log_success() { echo -e "\033[0;32m[OK]\033[0m $*"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $*"; }

# Check dependencies
check_deps() {
    local missing=()
    for cmd in inotifywait git systemctl; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing dependencies: ${missing[*]}"
        log_info "Install with: sudo apt install inotify-tools git systemd (or equivalent)"
        return 1
    fi
    return 0
}

# Make scripts executable
setup_scripts() {
    chmod +x "$SYNC_SCRIPT"
    log_success "Made sync script executable"
}

# Install systemd user service
install_service() {
    mkdir -p "$SERVICE_DIR"
    mkdir -p "$LOG_DIR"
    
    # Update service file with actual paths
    sed \
        -e "s|/home/clumzzy/Projects/Dotfiles|$DOTFILES_DIR|g" \
        -e "s|%h|$HOME|g" \
        "$SERVICE_FILE" > "$SERVICE_DIR/dotfiles-sync.service"
    
    sed \
        -e "s|/home/clumzzy/Projects/Dotfiles|$DOTFILES_DIR|g" \
        "$TIMER_FILE" > "$SERVICE_DIR/dotfiles-sync.timer"
    
    # Reload systemd
    systemctl --user daemon-reload
    
    log_success "Installed systemd service and timer to $SERVICE_DIR"
}

# Enable and start services
enable_services() {
    log_info "Enabling and starting services..."
    
    systemctl --user enable dotfiles-sync.service
    systemctl --user enable dotfiles-sync.timer
    
    systemctl --user start dotfiles-sync.service
    systemctl --user start dotfiles-sync.timer
    
    log_success "Services enabled and started"
}

# Show status
show_status() {
    echo
    log_info "=== Service Status ==="
    systemctl --user status dotfiles-sync.service --no-pager || true
    echo
    systemctl --user status dotfiles-sync.timer --no-pager || true
    echo
    
    log_info "=== Next Scheduled Runs ==="
    systemctl --user list-timers dotfiles-sync.timer --no-pager || true
}

# Setup initial config
setup_config() {
    "$SYNC_SCRIPT" --init-config
    
    # If git remote is not set, try to detect
    if [ -d "$DOTFILES_DIR/.git" ]; then
        local remote_url=$(cd "$DOTFILES_DIR" && git remote get-url origin 2>/dev/null || echo "")
        if [ -n "$remote_url" ]; then
            log_info "Detected git remote: $remote_url"
        else
            # Prompt for GitHub credentials to set up remote
            setup_github_remote
        fi
    fi
}

# Setup GitHub remote with credentials
setup_github_remote() {
    echo
    log_prompt "=== GitHub Remote Setup ==="
    echo "To enable monthly push to GitHub, we need to set up a remote."
    echo "You can use either SSH (recommended) or HTTPS with a Personal Access Token."
    echo
    
    read -r -p "Set up GitHub remote now? [Y/n] " setup_remote
    [[ "$setup_remote" =~ ^[Nn]$ ]] && { log_info "Skipping GitHub remote setup"; return 0; }
    
    echo
    echo "Choose method:"
    echo "  1) SSH (recommended) - git@github.com:username/repo.git"
    echo "  2) HTTPS with Personal Access Token - https://github.com/username/repo.git"
    echo
    read -r -p "Select [1-2] (default: 1): " method
    method="${method:-1}"
    
    read -r -p "GitHub username: " gh_user
    [ -z "$gh_user" ] && { log_error "Username required"; return 1; }
    
    read -r -p "Repository name (default: dotfiles): " gh_repo
    gh_repo="${gh_repo:-dotfiles}"
    
    local remote_url=""
    if [ "$method" = "1" ]; then
        # SSH
        remote_url="git@github.com:${gh_user}/${gh_repo}.git"
        log_info "Using SSH remote: $remote_url"
        log_warn "Make sure you have added your SSH key to GitHub!"
        log_warn "Run: cat ~/.ssh/id_ed25519.pub (or id_rsa.pub) and add to GitHub Settings > SSH Keys"
    else
        # HTTPS with PAT
        echo
        log_prompt "Enter GitHub Personal Access Token (input hidden): "
        read -rs gh_token
        echo
        [ -z "$gh_token" ] && { log_error "Token required for HTTPS"; return 1; }
        remote_url="https://${gh_user}:${gh_token}@github.com/${gh_user}/${gh_repo}.git"
        log_info "Using HTTPS remote with token"
    fi
    
    # Add remote
    cd "$DOTFILES_DIR"
    if git remote add origin "$remote_url" 2>/dev/null; then
        log_success "Added remote 'origin': $remote_url"
    else
        log_warn "Remote 'origin' already exists, updating..."
        git remote set-url origin "$remote_url"
        log_success "Updated remote 'origin': $remote_url"
    fi
    
    # Test connection
    log_info "Testing connection..."
    if git ls-remote origin HEAD &>/dev/null; then
        log_success "GitHub remote configured successfully!"
    else
        log_warn "Could not connect to remote. Please verify credentials and repository exists."
        log_warn "You can manually fix with: cd $DOTFILES_DIR && git remote set-url origin <url>"
    fi
    
    # Set upstream branch
    git branch -M main 2>/dev/null || true
    
    echo
}

# Main
main() {
    case "${1:-}" in
        --setup-github)
            setup_github_remote
            exit 0
            ;;
    esac
    
    log_info "Installing dotfiles sync daemon..."
    
    check_deps || exit 1
    setup_scripts
    setup_config
    install_service
    enable_services
    show_status
    
    echo
    log_success "Installation complete!"
    echo
    echo "Commands:"
    echo "  systemctl --user status dotfiles-sync.service  # Check daemon status"
    echo "  systemctl --user logs -f dotfiles-sync.service  # Follow logs"
    echo "  $SYNC_SCRIPT --status                           # Show sync status"
    echo "  $SYNC_SCRIPT --sync                             # Manual sync"
    echo "  $SYNC_SCRIPT --setup-github                     # Setup GitHub remote"
    echo
    echo "Config: ~/.config/dotfiles-sync.conf"
    echo "Logs: journalctl --user -u dotfiles-sync.service -f"
}

main "$@"