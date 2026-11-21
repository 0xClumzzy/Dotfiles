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
        fi
    fi
}

# Main
main() {
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
    echo
    echo "Config: ~/.config/dotfiles-sync.conf"
    echo "Logs: journalctl --user -u dotfiles-sync.service -f"
}

main "$@"