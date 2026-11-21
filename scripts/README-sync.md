# Dotfiles Auto-Sync System

Automatically commits dotfile changes and pushes to GitHub monthly.

## Components

| File | Purpose |
|------|---------|
| `sync-dotfiles.sh` | Main daemon - watches files, commits, pushes |
| `dotfiles-sync.service` | Systemd service (runs watcher) |
| `dotfiles-sync.timer` | Systemd timer (monthly push) |
| `install-sync.sh` | One-command installer |

## Quick Install

```bash
cd /home/clumzzy/Projects/Dotfiles/scripts
./install-sync.sh
```

This will:
1. Install systemd user service + timer
2. Create default config at `~/.config/dotfiles-sync.conf`
3. Start the file watcher daemon
4. Schedule monthly push (1st of month, 3 AM)

## How It Works

### File Watcher (Continuous)
- Uses `inotifywait` to monitor `~/Projects/Dotfiles`
- Debounces changes (default 5 min) to avoid commit spam
- Auto-commits with descriptive messages
- Pushes immediately if it's monthly push time

### Monthly Push (Timer)
- Systemd timer triggers on 1st of month at 3 AM
- Pushes all accumulated commits to GitHub
- Tracks last push month to avoid duplicates

## Manual Usage

```bash
# Single sync cycle (pull → commit → push if monthly)
./sync-dotfiles.sh --sync

# Force monthly push now
./sync-dotfiles.sh --monthly-push

# Show status
./sync-dotfiles.sh --status

# Run watcher manually (foreground)
./sync-dotfiles.sh --watch
```

## Systemd Commands

```bash
# Check daemon status
systemctl --user status dotfiles-sync.service

# Follow logs live
journalctl --user -u dotfiles-sync.service -f

# View timer schedule
systemctl --user list-timers dotfiles-sync.timer

# Restart daemon
systemctl --user restart dotfiles-sync.service

# Stop everything
systemctl --user stop dotfiles-sync.service dotfiles-sync.timer
systemctl --user disable dotfiles-sync.service dotfiles-sync.timer
```

## Configuration

Edit `~/.config/dotfiles-sync.conf`:

```bash
# Git remote to push to
REMOTE_NAME="origin"

# Branch to track
BRANCH="main"

# Seconds to wait before committing (debounce)
COMMIT_DELAY=300

# Monthly push: day of month (1-28) and time
MONTHLY_PUSH_DAY=1
PUSH_TIME="03:00"

# Optional: Custom git identity for auto-commits
# GIT_AUTHOR_NAME="Your Name"
# GIT_AUTHOR_EMAIL="you@example.com"
```

## Requirements

- `inotify-tools` (inotifywait)
- `git`
- `systemd` (user services)
- GitHub remote configured with push access (SSH key or PAT)

## Troubleshooting

### Push fails with authentication
```bash
# Check remote URL
cd ~/Projects/Dotfiles && git remote -v

# Test push manually
git push origin main

# Use SSH key or GitHub PAT
gh auth login  # or add SSH key to GitHub
```

### Watcher not detecting changes
```bash
# Check inotify limits
cat /proc/sys/fs/inotify/max_user_watches
# Increase if needed:
echo 524288 | sudo tee /proc/sys/fs/inotify/max_user_watches
```

### Service won't start
```bash
# Check logs
journalctl --user -u dotfiles-sync.service -n 50

# Check config syntax
bash -n ~/Projects/Dotfiles/scripts/sync-dotfiles.sh
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Machine                              │
├─────────────────────────────────────────────────────────────┤
│  ~/.config/systemd/user/                                     │
│  ├── dotfiles-sync.service  ──► sync-dotfiles.sh --watch    │
│  └── dotfiles-sync.timer   ──► monthly push trigger         │
│                                                              │
│  ~/Projects/Dotfiles/ (git repo)                            │
│  ├── .git/                                                  │
│  └── ... dotfiles ...                                       │
│                                                              │
│  ~/.config/dotfiles-sync.conf  (user config)                │
│  ~/.local/state/dotfiles-sync.log  (activity log)           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (monthly, or on demand)
┌─────────────────────────────────────────────────────────────┐
│                      GitHub                                  │
│  Remote repository receives pushed commits                  │
└─────────────────────────────────────────────────────────────┘
```

## Security Notes

- Service runs as your user (no root)
- `ProtectHome=read-only` - only writes to `~/Projects/Dotfiles` and state dirs
- Git credentials use your existing SSH keys / git config
- No secrets stored in config file