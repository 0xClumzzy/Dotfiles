#!/usr/bin/env bash
# Dotfiles auto-sync daemon
# Watches for changes, commits locally, pushes monthly
# Config: ~/.config/dotfiles-sync.conf (per-machine)

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Projects/Dotfiles}"
CONFIG_FILE="$HOME/.config/dotfiles-sync.conf"
LOG_FILE="$HOME/.local/state/dotfiles-sync.log"
LOCK_FILE="/tmp/dotfiles-sync.lock"

# ============ DEFAULTS (overridden by config file) ============
REMOTE_NAME="origin"
BRANCH="main"

# Watcher settings
COMMIT_DELAY=300              # debounce seconds
WATCH_EVENTS="modify,create,delete,move"
WATCH_RECURSIVE=true
EXCLUDE_PATTERNS=(
    ".git"
    "*.log"
    "*.swp"
    "*.tmp"
    "*.sw?"
    "node_modules"
    ".DS_Store"
    "*.bak"
    "*~"
)
INOTIFYWAIT_OPTS=()

# Monthly push settings
MONTHLY_PUSH_DAY=1
PUSH_TIME="03:00"

# Git identity for auto-commits (optional)
GIT_AUTHOR_NAME=""
GIT_AUTHOR_EMAIL=""

# ============ LOAD USER CONFIG ============
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$CONFIG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2
}

# Check if another instance is running
check_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local pid=$(cat "$LOCK_FILE" 2>/dev/null)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            return 1
        fi
    fi
    echo $$ > "$LOCK_FILE"
    return 0
}

release_lock() {
    rm -f "$LOCK_FILE"
}

# Set git identity for this repo if configured
setup_git_identity() {
    cd "$DOTFILES_DIR" || return 1
    if [ -n "$GIT_AUTHOR_NAME" ]; then
        git config user.name "$GIT_AUTHOR_NAME"
    fi
    if [ -n "$GIT_AUTHOR_EMAIL" ]; then
        git config user.email "$GIT_AUTHOR_EMAIL"
    fi
}

# Git operations
git_commit() {
    cd "$DOTFILES_DIR" || return 1
    
    # Check if there are changes
    if git diff --quiet && git diff --cached --quiet; then
        return 0
    fi
    
    if [ -n "$(git status --porcelain)" ]; then
        log "Changes detected, committing..."
        
        setup_git_identity
        git add -A
        
        local changed_files=$(git diff --cached --name-only | head -20 | tr '\n' ' ')
        local commit_msg="auto: sync dotfiles - $(date '+%Y-%m-%d %H:%M') - $changed_files"
        
        if git commit -m "$commit_msg" >> "$LOG_FILE" 2>&1; then
            log "Committed: $commit_msg"
            return 0
        else
            log_error "Failed to commit"
            return 1
        fi
    fi
    return 0
}

git_pull() {
    cd "$DOTFILES_DIR" || return 1
    
    if ! git remote get-url "$REMOTE_NAME" &>/dev/null; then
        log "No remote '$REMOTE_NAME' configured, skipping pull"
        return 0
    fi
    
    log "Pulling from $REMOTE_NAME/$BRANCH..."
    
    if git pull --rebase "$REMOTE_NAME" "$BRANCH" >> "$LOG_FILE" 2>&1; then
        log "Pull successful"
        return 0
    else
        log_error "Pull failed - may need manual resolution"
        return 1
    fi
}

git_push() {
    cd "$DOTFILES_DIR" || return 1
    
    if ! git remote get-url "$REMOTE_NAME" &>/dev/null; then
        log "No remote '$REMOTE_NAME' configured, skipping push"
        return 0
    fi
    
    log "Pushing to $REMOTE_NAME/$BRANCH..."
    
    if git push "$REMOTE_NAME" "$BRANCH" >> "$LOG_FILE" 2>&1; then
        log "Push successful"
        return 0
    else
        log_error "Push failed - check credentials/remote"
        return 1
    fi
}

should_push_monthly() {
    local current_day=$(date '+%d')
    local current_time=$(date '+%H:%M')
    
    if [ "$current_day" = "$MONTHLY_PUSH_DAY" ]; then
        local push_hour=$(echo "$PUSH_TIME" | cut -d: -f1)
        local push_min=$(echo "$PUSH_TIME" | cut -d: -f2)
        local push_total=$((push_hour * 60 + push_min))
        
        local current_hour=$(date '+%H')
        local current_min=$(date '+%M')
        local current_total=$((current_hour * 60 + current_min))
        
        if [ "$current_total" -ge "$push_total" ]; then
            local last_push_file="$HOME/.local/state/dotfiles-last-push"
            local last_push_month=""
            if [ -f "$last_push_file" ]; then
                last_push_month=$(cat "$last_push_file")
            fi
            local current_month=$(date '+%Y-%m')
            
            if [ "$last_push_month" != "$current_month" ]; then
                echo "$current_month" > "$last_push_file"
                return 0
            fi
        fi
    fi
    return 1
}

# Watch for changes using inotifywait
watch_changes() {
    log "Starting file watcher on $DOTFILES_DIR"
    log "Config: delay=${COMMIT_DELAY}s, events=${WATCH_EVENTS}, excludes=${#EXCLUDE_PATTERNS[@]} patterns"
    
    local inotify_args=(
        -r
        -e "$WATCH_EVENTS"
        --format '%w%f %e %T'
        --timefmt '%Y-%m-%d %H:%M:%S'
    )
    
    if [ "$WATCH_RECURSIVE" != "true" ]; then
        # Remove -r if not recursive
        inotify_args=("${inotify_args[@]/-r/}")
    fi
    
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        inotify_args+=(--exclude "$pattern")
    done
    
    for opt in "${INOTIFYWAIT_OPTS[@]}"; do
        inotify_args+=("$opt")
    done
    
    inotify_args+=("$DOTFILES_DIR")
    
    local last_commit_time=0
    
    while read -r file event timestamp; do
        log "Change: $event on $file"
        
        local current_time=$(date '+%s')
        local time_diff=$((current_time - last_commit_time))
        
        if [ "$time_diff" -ge "$COMMIT_DELAY" ]; then
            git_commit
            last_commit_time=$current_time
        else
            log "Debouncing... ($time_diff/$COMMIT_DELAY seconds)"
        fi
        
        if should_push_monthly; then
            log "Monthly push triggered"
            git_push
        fi
        
    done < <(inotifywait "${inotify_args[@]}" 2>>"$LOG_FILE")
}

sync_once() {
    log "Running sync cycle..."
    
    if ! check_lock; then
        log "Another sync is running, skipping"
        return 0
    fi
    
    git_pull
    git_commit
    
    if should_push_monthly; then
        git_push
    fi
    
    release_lock
}

show_status() {
    cd "$DOTFILES_DIR" 2>/dev/null || { log_error "Not a git repo: $DOTFILES_DIR"; return 1; }
    
    echo "=== Dotfiles Sync Status ==="
    echo "Directory: $DOTFILES_DIR"
    echo "Remote: $REMOTE_NAME/$BRANCH"
    echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    echo "Last commit: $(git log -1 --format='%h %s (%cr)' 2>/dev/null || echo 'none')"
    echo "Status: $(git status --short 2>/dev/null | wc -l) files changed"
    echo
    echo "Watcher Config:"
    echo "  Debounce: ${COMMIT_DELAY}s"
    echo "  Events: $WATCH_EVENTS"
    echo "  Recursive: $WATCH_RECURSIVE"
    echo "  Excludes: ${#EXCLUDE_PATTERNS[@]} patterns"
    echo
    echo "Monthly Push:"
    echo "  Day: $MONTHLY_PUSH_DAY"
    echo "  Time: $PUSH_TIME"
    echo "  Next: $(date -d "$(date '+%Y-%m')-$MONTHLY_PUSH_DAY $PUSH_TIME" '+%Y-%m-%d %H:%M' 2>/dev/null || echo 'N/A')"
    echo
    echo "Log: $LOG_FILE"
    echo "Config: $CONFIG_FILE"
}

create_config() {
    cat > "$CONFIG_FILE" <<'EOF'
# Dotfiles Sync Configuration
# Per-machine config - edit freely, won't be synced
# Generated on $(date)

# ============ GIT SETTINGS ============
# Git remote to push to
REMOTE_NAME="origin"

# Branch to track
BRANCH="main"

# ============ WATCHER SETTINGS ============
# Seconds to wait before committing after changes (debounce)
COMMIT_DELAY=300

# inotifywait events to watch (comma-separated)
# Options: access,modify,attrib,close_write,close_nowrite,open,moved_to,moved_from,move,create,delete,delete_self,move_self
WATCH_EVENTS="modify,create,delete,move"

# Watch recursively (true/false)
WATCH_RECURSIVE=true

# Patterns to exclude (one per line in array)
# Uses inotifywait --exclude regex patterns
EXCLUDE_PATTERNS=(
    ".git"
    "*.log"
    "*.swp"
    "*.tmp"
    "*.sw?"
    "node_modules"
    ".DS_Store"
    "*.bak"
    "*~"
)

# Additional inotifywait options (e.g., "--quiet" "--daemon")
INOTIFYWAIT_OPTS=()

# ============ MONTHLY PUSH ============
# Day of month to push (1-28)
MONTHLY_PUSH_DAY=1

# Time to push (HH:MM 24-hour)
PUSH_TIME="03:00"

# ============ GIT IDENTITY (optional) ============
# Used for auto-commits. If empty, uses global git config.
# GIT_AUTHOR_NAME="Your Name"
# GIT_AUTHOR_EMAIL="you@example.com"
EOF
    log "Created default config at $CONFIG_FILE"
}

# Main
main() {
    case "${1:-}" in
        --watch)
            if ! check_lock; then
                log_error "Another instance is running (PID: $(cat $LOCK_FILE 2>/dev/null))"
                exit 1
            fi
            trap release_lock EXIT
            watch_changes
            ;;
        --sync)
            sync_once
            ;;
        --monthly-push)
            cd "$DOTFILES_DIR" && git_push
            ;;
        --status)
            show_status
            ;;
        --init-config)
            create_config
            ;;
        *)
            echo "Usage: $0 {--watch|--sync|--monthly-push|--status|--init-config}"
            echo
            echo "Modes:"
            echo "  --watch         Run continuous file watcher (daemon mode)"
            echo "  --sync          Single sync cycle (for systemd timer/cron)"
            echo "  --monthly-push  Force monthly push"
            echo "  --status        Show sync status and config"
            echo "  --init-config   Create default config file at ~/.config/dotfiles-sync.conf"
            echo
            echo "Config file: $CONFIG_FILE (per-machine, not synced)"
            echo "Log file: $LOG_FILE"
            exit 1
            ;;
    esac
}

main "$@"