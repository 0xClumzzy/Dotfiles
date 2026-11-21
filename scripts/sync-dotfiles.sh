#!/usr/bin/env bash
# Dotfiles auto-sync daemon
# Watches for changes, commits locally, pushes monthly

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-/home/clumzzy/Projects/Dotfiles}"
CONFIG_FILE="$HOME/.config/dotfiles-sync.conf"
LOG_FILE="$HOME/.local/state/dotfiles-sync.log"
PID_FILE="/tmp/dotfiles-sync.pid"
LOCK_FILE="/tmp/dotfiles-sync.lock"

# Default config
REMOTE_NAME="origin"
BRANCH="main"
COMMIT_DELAY=300  # seconds to wait before committing (debounce)
MONTHLY_PUSH_DAY=1  # day of month to push (1 = 1st)
PUSH_TIME="03:00"  # time to push (3 AM)

# Load user config
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

# Git operations
git_commit() {
    cd "$DOTFILES_DIR" || return 1
    
    # Check if there are changes
    if git diff --quiet && git diff --cached --quiet; then
        return 0
    fi
    
    # Check for untracked files
    if [ -n "$(git status --porcelain)" ]; then
        log "Changes detected, committing..."
        
        # Add all changes
        git add -A
        
        # Create commit message with timestamp and file list
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

git_push() {
    cd "$DOTFILES_DIR" || return 1
    
    # Skip if no remote configured
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

git_pull() {
    cd "$DOTFILES_DIR" || return 1
    
    # Skip if no remote configured
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

# Check if it's time for monthly push
should_push_monthly() {
    local current_day=$(date '+%d')
    local current_time=$(date '+%H:%M')
    
    # Check if it's the push day and after push time
    if [ "$current_day" = "$MONTHLY_PUSH_DAY" ]; then
        # Convert times to minutes for comparison
        local push_hour=$(echo "$PUSH_TIME" | cut -d: -f1)
        local push_min=$(echo "$PUSH_TIME" | cut -d: -f2)
        local push_total=$((push_hour * 60 + push_min))
        
        local current_hour=$(date '+%H')
        local current_min=$(date '+%M')
        local current_total=$((current_hour * 60 + current_min))
        
        if [ "$current_total" -ge "$push_total" ]; then
            # Check if we already pushed this month
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
    
    # Exclude patterns
    local exclude_patterns=(
        ".git"
        "*.log"
        "*.swp"
        "*.tmp"
        "node_modules"
        ".DS_Store"
    )
    
    local inotify_args=(
        -r
        -e modify,create,delete,move
        --format '%w%f %e %T'
        --timefmt '%Y-%m-%d %H:%M:%S'
    )
    
    # Add exclusions
    for pattern in "${exclude_patterns[@]}"; do
        inotify_args+=(--exclude "$pattern")
    done
    
    inotify_args+=("$DOTFILES_DIR")
    
    # Debounce timer
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
        
        # Check for monthly push
        if should_push_monthly; then
            log "Monthly push triggered"
            git_push
        fi
        
    done < <(inotifywait "${inotify_args[@]}" 2>>"$LOG_FILE")
}

# Single sync cycle (for cron/systemd timer)
sync_once() {
    log "Running sync cycle..."
    
    if ! check_lock; then
        log "Another sync is running, skipping"
        return 0
    fi
    
    # Pull first to get remote changes
    git_pull
    
    # Commit local changes
    git_commit
    
    # Push if monthly
    if should_push_monthly; then
        git_push
    fi
    
    release_lock
}

# Setup cron job for monthly push
setup_cron() {
    local cron_entry="0 $(echo "$PUSH_TIME" | cut -d: -f2) $(echo "$PUSH_TIME" | cut -d: -f1) $MONTHLY_PUSH_DAY * * $0 --monthly-push >> $LOG_FILE 2>&1"
    
    log "Setting up cron job for monthly push..."
    
    # Add to user crontab
    (crontab -l 2>/dev/null | grep -v "dotfiles-sync"; echo "$cron_entry") | crontab -
    
    log "Cron job installed"
}

# Show status
show_status() {
    cd "$DOTFILES_DIR" 2>/dev/null || { log_error "Not a git repo: $DOTFILES_DIR"; return 1; }
    
    echo "=== Dotfiles Sync Status ==="
    echo "Directory: $DOTFILES_DIR"
    echo "Remote: $REMOTE_NAME/$BRANCH"
    echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    echo "Last commit: $(git log -1 --format='%h %s (%cr)' 2>/dev/null || echo 'none')"
    echo "Status: $(git status --short 2>/dev/null | wc -l) files changed"
    echo "Log: $LOG_FILE"
    echo "Config: $CONFIG_FILE"
    echo
    echo "Next monthly push: $(date -d "$(date '+%Y-%m')-$MONTHLY_PUSH_DAY $PUSH_TIME" '+%Y-%m-%d %H:%M')"
}

# Create default config
create_config() {
    cat > "$CONFIG_FILE" <<EOF
# Dotfiles Sync Configuration
# Generated on $(date)

# Git remote to push to
REMOTE_NAME="origin"

# Branch to track
BRANCH="main"

# Seconds to wait before committing after changes (debounce)
COMMIT_DELAY=300

# Monthly push settings
MONTHLY_PUSH_DAY=1
PUSH_TIME="03:00"

# Optional: Custom git identity for commits
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
                log_error "Another instance is running (PID: $(cat $LOCK_FILE))"
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
        --setup-cron)
            setup_cron
            ;;
        --status)
            show_status
            ;;
        --init-config)
            create_config
            ;;
        *)
            echo "Usage: $0 {--watch|--sync|--monthly-push|--setup-cron|--status|--init-config}"
            echo
            echo "Modes:"
            echo "  --watch         Run continuous file watcher (daemon mode)"
            echo "  --sync          Single sync cycle (for systemd timer/cron)"
            echo "  --monthly-push  Force monthly push"
            echo "  --setup-cron    Install monthly push cron job"
            echo "  --status        Show sync status"
            echo "  --init-config   Create default config file"
            echo
            echo "Config file: $CONFIG_FILE"
            exit 1
            ;;
    esac
}

main "$@"