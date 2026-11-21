# 🏗️ Dotfiles

A clean, modular, cross-platform dotfiles configuration with **transparent backgrounds**, **cursive italics**, **auto-sync to GitHub**, and **terminal-agnostic configs**.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **🎨 Transparent + Cursive** | True black (`#000000`) background with italic comments/keywords/functions in Neovim |
| **✍️ icursive-nerd-font** | Default font with 9 cursive variants (Meslo, FiraCode, Hack, JetBrains, Fantasque, etc.) |
| **🔄 Auto-Sync Daemon** | Systemd service watches for changes, commits locally, pushes to GitHub monthly |
| **🔧 Terminal-Agnostic** | Ghostty + Terminator configs synced via symlinks |
| **🐚 Modular Shell** | Shared bash/zsh modules (exports, path, aliases, functions) |
| **📦 Lazy.nvim IDE** | LSP, Telescope, Treesitter, Git, Debug, Test, REST client |
| **🔄 GitHub Auto-Push** | Interactive SSH/HTTPS+PAT setup, monthly automated push |

---

## 📁 Structure

```
dotfiles/
├── .config/
│   ├── bash/           # bashrc, exports.sh, path.sh, aliases.sh (shared)
│   ├── zsh/            # zshrc (sources bash + OMZ plugins)
│   ├── starship/       # Noctalia monochrome theme
│   ├── nvim/           # Modular LazyVim config
│   ├── git/            # Git config + global ignore
│   ├── micro/          # Micro editor settings/bindings
│   ├── ghostty/        # Ghostty terminal config
│   └── terminator/     # Terminator terminal config
├── scripts/
│   ├── install-fonts.sh    # Nerd Font installer (icursive + fallbacks)
│   ├── install-sync.sh     # Auto-sync systemd service installer
│   ├── sync-dotfiles.sh    # File watcher + monthly push
│   └── install-all.sh      # Universal interactive installer
├── install.sh          # Main installer (minimal/terminals-only modes)
├── install-all.sh      # Universal component installer
└── README.md
```

---

## 🚀 Quick Start

```bash
# Clone
git clone https://github.com/YOURUSER/dotfiles.git ~/Projects/Dotfiles
cd ~/Projects/Dotfiles

# Interactive component installer (recommended)
./install-all.sh

# Or install everything at once
./install-all.sh --all

# Minimal: shell + starship only
./install.sh --minimal

# Terminals only (ghostty + terminator)
./install.sh --terminals-only

# Fonts: icursive (cursive) + fallback fonts
./scripts/install-fonts.sh -d

# Auto-sync daemon (systemd + GitHub remote)
./scripts/install-sync.sh
```

### Non-Interactive / CI

```bash
# All components, no prompts
./install-all.sh --all --non-interactive

# Just fonts (icursive + 2 fallbacks)
./scripts/install-fonts.sh -d -i 0,2,3

# Just dotfiles
./install.sh --minimal --non-interactive
```

---

## 🎨 Fonts

### Default: **icursive-nerd-font** (Cursive Italics)

Installs 9 patched variants from [thlineric/icursive-nerd-font](https://github.com/thlineric/icursive-nerd-font):

| Variant | Base Font |
|---------|-----------|
| Meslo iCursive S12 | MesloLGS |
| Fira Code iCursive S12 | FiraCode |
| Hack iCursive S12 | Hack |
| JetBrains Mono iCursive | JetBrainsMono |
| Fantasque iCursive Dk/Op | FantasqueSansMono |
| InconsolataGo iCursive Pb | InconsolataGo |
| InconsolataLGC iCursive S12 | InconsolataLGC |
| Roboto Mono iCursive Pt | RobotoMono |
| Source Code Pro iCursive S12 | SourceCodePro |

### Fallback Fonts (installed via `-d` flag)

| Font | Description |
|------|-------------|
| JetBrainsMono Nerd Font | Clean, great italics |
| FiraCode Nerd Font | Famous ligatures |
| MesloLGS Nerd Font | Classic terminal |
| Hack Nerd Font | Source code optimized |
| Source Code Pro Nerd Font | Professional |
| VictorMono Nerd Font | Unique cursive |

### Font Commands

```bash
# Interactive selector with preview
./scripts/install-fonts.sh

# Default stack: icursive + 2 fallbacks
./scripts/install-fonts.sh -d

# Install specific fonts (comma-separated)
./scripts/install-fonts.sh -i 0,2,3

# Update all fonts to latest
./scripts/install-fonts.sh -u

# List installed font families
./scripts/install-fonts.sh -l
```

### Terminal Setup

After installing, set your terminal font to one of the installed families:

- **Ghostty**: `font-family = "JetBrainsMono Nerd Font"` (in `~/.config/ghostty/config`)
- **Terminator**: `font = "JetBrainsMono Nerd Font 17"` (in `~/.config/terminator/config`)
- **Alacritty/Kitty/WezTerm**: Use font name from `fc-list | grep -i nerd`

**Enable italic** in terminal settings for cursive comments/keywords.

---

## 🐚 Shell Configuration

### Modular Structure (Shared bash/zsh)

```
.config/bash/
├── bashrc        # Entry point (sources modules)
├── exports.sh    # ENV vars: EDITOR, PATH, XDG, colors, locale
├── path.sh       # PATH management (prepend/append helpers)
└── aliases.sh    # 300+ aliases + functions
```

### Key Aliases

```bash
# Navigation
..          cd ..
...         cd ../..
htbdir foo  mkdir -p ~/ctfs/htb/foo && cd $_

# Git
gcom "msg"  git add -A && git commit -m "msg"
lazyg "msg" git add -A && git commit -m "msg" && git push

# CTF/Security
ms          ~/scripts/BASH/combo.sh
vpn         ~/scripts/BASH/vpnc.sh
rs          ~/scripts/BASH/rustscan.sh
htbdir      ~/scripts/BASH/htbdir.sh

# Utils
whatsmyip   # Internal + external IP
extract foo.tar.gz  # Auto-detect archive type
mkcd foo    mkdir -p foo && cd foo
```

### Zsh Extras

- **Oh My Zsh** + plugins: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab`
- **History**: 50k lines, shared across sessions, deduped
- **Completion**: Case-insensitive, menu select, cached

---

## 🎯 Neovim (Lazy.nvim)

### Plugin Categories

| Category | Plugins |
|----------|---------|
| **UI** | lualine, bufferline, noice, notify, indent-blankline, which-key |
| **Editor** | autopairs, surround, Comment, todo-comments, mini.ai, hop |
| **LSP** | nvim-lspconfig, mason, nvim-cmp, conform, nvim-lint, trouble |
| **Treesitter** | highlight, textobjects, context, incremental selection |
| **Telescope** | find_files, live_grep, buffers, lsp_symbols, projects |
| **Git** | gitsigns, fugitive, lazygit, diffview |
| **Terminal** | toggleterm |
| **Utility** | neo-tree, persistence, spectre, kulala, dadbod, neotest |

### Key Bindings

| Key | Action |
|-----|--------|
| `<Space>` | Leader |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>e` | Toggle neo-tree |
| `<leader>gg` | Git status (fugitive) |
| `<leader>lg` | LazyGit |
| `<C-\\>` | Toggle terminal |
| `jk` / `kj` | Escape insert mode |
| `<leader>cf` | Format buffer |
| `<leader>xx` | Toggle diagnostics (Trouble) |
| `f` / `F` | Hop char forward/back |

### LSP Servers (auto-installed via Mason)

`lua_ls`, `pyright`, `rust_analyzer`, `gopls`, `ts_ls`, `html`, `cssls`, `jsonls`, `yamlls`, `bashls`, `dockerls`

---

## ⭐ Starship Prompt

**Noctalia Monochrome Theme** — true black transparent background with cursive italics.

### Features

- Two-line prompt with rounded powerline separators
- Git branch/status with ahead/behind/diverged icons
- Language versions (Node, Rust, Go) shown only in relevant dirs
- Battery with low-warning styling
- Command duration (>2s) + notifications (>30s)
- Time on right side
- Custom Arch distro indicator

### Customization

```toml
# ~/.config/starship.toml
# Toggle transparency
# <leader>tT  # In Neovim, or edit starship.toml directly
```

---

## 🔄 Auto-Sync Daemon

### Features

- **File watcher** (`inotifywait`): Debounced commits (default 5min)
- **Monthly push**: 1st of month at 3 AM (configurable)
- **Systemd user service**: Auto-starts on login
- **GitHub remote setup**: Interactive SSH/HTTPS+PAT prompts

### Commands

```bash
# Install daemon
./scripts/install-sync.sh

# Manual sync (pull → commit → push if monthly)
./scripts/sync-dotfiles.sh --sync

# Force monthly push now
./scripts/sync-dotfiles.sh --monthly-push

# Show status
./scripts/sync-dotfiles.sh --status

# Generate config
./scripts/sync-dotfiles.sh --init-config
```

### Systemd Commands

```bash
systemctl --user status dotfiles-sync.service
systemctl --user logs -f dotfiles-sync.service
systemctl --user list-timers dotfiles-sync.timer
systemctl --user restart dotfiles-sync.service
```

### Config (`~/.config/dotfiles-sync.conf`)

```bash
REMOTE_NAME="origin"
BRANCH="main"
COMMIT_DELAY=300
WATCH_EVENTS="modify,create,delete,move"
EXCLUDE_PATTERNS=(".git" "*.log" "*.swp" "*.tmp" "node_modules" ".DS_Store")
MONTHLY_PUSH_DAY=1
PUSH_TIME="03:00"
# Optional git identity for auto-commits
# GIT_AUTHOR_NAME="Your Name"
# GIT_AUTHOR_EMAIL="you@example.com"
```

---

## 🖥️ Terminal Configs

### Ghostty (`~/.config/ghostty/config`)

```ini
background-opacity = 0.82
background-blur = 22
background = #000000
font-family = "JetBrainsMono Nerd Font"
font-style-italic = "JetBrainsMono Nerd Font Italic"
font-size = 19
font-thicken = true
scrollback-limit = 100000
copy-on-select = clipboard
```

### Terminator (`~/.config/terminator/config`)

```ini
[global_config]
  focus = mouse
  window_state = maximise

[profiles]
  [[default]]
    background_type = transparent
    font = "JetBrainsMono Nerd Font 17"
    copy_on_selection = True
```

---

## 📦 Package Requirements

### Core (auto-installed on supported distros)

```bash
# Arch/Manjaro
sudo pacman -S zsh git curl wget unzip neovim starship zoxide fzf eza bat fd ripgrep trash-cli fastfetch thefuck direnv atuin lazygit docker go rust nodejs python3 python3-pip pipx inotify-tools

# Debian/Ubuntu
sudo apt install zsh git curl wget unzip neovim starship zoxide fzf eza bat fd-find ripgrep trash-cli fastfetch thefuck direnv atuin lazygit docker.io golang rustc cargo nodejs npm python3 python3-pip pipx inotify-tools

# Fedora
sudo dnf install zsh git curl wget unzip neovim starship zoxide fzf eza bat fd-find ripgrep trash-cli fastfetch thefuck direnv atuin lazygit docker golang rust cargo nodejs npm python3 python3-pip pipx inotify-tools

# macOS (Homebrew)
brew install zsh git curl wget neovim starship zoxide fzf eza bat fd ripgrep trash fastfetch thefuck direnv atuin lazygit docker go rust node python3 pipx inotify-tools
```

### Optional

```bash
# Nerd Fonts (via install-fonts.sh)
# Oh My Zsh (auto-installed)
# Mason LSP servers (auto-installed on first nvim run)
```

---

## 🛠️ Development

### Adding New Components

1. Add config to `.config/`
2. Update `install.sh` to symlink new configs
2. Add component to `COMPONENTS` array in `install-all.sh`
3. Add `check_installed` case for status detection

### Local Overrides (not tracked)

```bash
# Shell
~/.bashrc.local
~/.zshrc.local

# Neovim
~/.config/nvim/lua/local.lua
```

---

## 📝 License

MIT — Feel free to fork, modify, and use.

---

## 🙏 Credits

- [thlineric/icursive-nerd-font](https://github.com/thlineric/icursive-nerd-font) — Cursive italic patched fonts
- [sainnhe/gruvbox-material](https://github.com/sainnhe/gruvbox-material) — Theme inspiration
- [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) — Colorscheme
- [starship/starship](https://github.com/starship/starship) — Prompt
- [LazyVim](https://github.com/LazyVim/LazyVim) — Neovim config structure inspiration