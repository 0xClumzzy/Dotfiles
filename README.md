# Dotfiles

A clean, modular dotfiles configuration for Linux/macOS with support for bash, zsh, Neovim, and more.

## Features

- **Modular shell config** - Shared exports, PATH, aliases, and functions between bash and zsh
- **Modern prompt** - Starship with custom Noctalia monochrome theme
- **Neovim IDE** - Lazy.nvim plugin manager with LSP, Treesitter, Telescope, and more
- **Cross-platform** - Works on Arch, Debian/Ubuntu, Fedora, macOS, and more
- **CTF/Security focused** - Includes aliases and functions for penetration testing workflows

## Structure

```
.config/
├── bash/
│   ├── bashrc          # Bash entry point
│   ├── exports.sh      # Environment variables (shared)
│   ├── path.sh         # PATH management (shared)
│   └── aliases.sh      # Aliases & functions (shared)
├── zsh/
│   └── zshrc           # Zsh entry point (sources bash modules)
├── starship/
│   └── starship.toml   # Starship prompt config
├── nvim/
│   ├── init.lua        # Neovim entry point
│   └── lua/
│       ├── config/     # Core config (options, keymaps, autocmds, LSP)
│       └── plugins/    # Lazy.nvim plugin specs
├── git/
│   ├── config          # Git config
│   └── ignore          # Global gitignore
└── micro/
    ├── settings.json   # Micro editor settings
    └── bindings.json   # Micro keybindings
```

## Quick Install

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles
./install.sh
```

Options:
- `--force` - Overwrite existing configs without prompting
- `--minimal` - Install only shell configs (bash, zsh, starship)

## Manual Installation

### Shell (bash/zsh)

```bash
# Bash
ln -sf ~/.config/dotfiles/.config/bash/bashrc ~/.bashrc

# Zsh
ln -sf ~/.config/dotfiles/.config/zsh/zshrc ~/.zshrc

# Starship
mkdir -p ~/.config
ln -sf ~/.config/dotfiles/.config/starship/starship.toml ~/.config/starship.toml
```

### Neovim

```bash
ln -sf ~/.config/dotfiles/.config/nvim ~/.config/nvim
```

## Key Bindings

### Shell
| Key | Action |
|-----|--------|
| `Ctrl+f` | Zoxide interactive (zi) |
| `Ctrl+r` | History search |
| `f` / `F` | Hop char forward/back (in nvim) |

### Neovim
| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>e` | Toggle file explorer |
| `<leader>gg` | Git status (fugitive) |
| `<leader>lg` | LazyGit |
| `<C-\\>` | Toggle terminal |
| `jk` / `kj` | Escape insert mode |
| `<leader>cf` | Format buffer |
| `<leader>xx` | Toggle diagnostics |

## Included Tools

### Shell
- **starship** - Cross-shell prompt
- **zoxide** - Smart cd replacement
- **fzf** - Fuzzy finder
- **eza** - Modern ls replacement
- **bat** - Cat with syntax highlighting
- **fd** - Fast find alternative
- **ripgrep** - Fast grep alternative
- **zsh-autosuggestions** - Fish-like autosuggestions
- **zsh-syntax-highlighting** - Syntax highlighting
- **thefuck** - Correct previous command
- **direnv** - Per-project env vars
- **atuin** - Shell history sync

### Neovim Plugins
- **lazy.nvim** - Plugin manager
- **nvim-lspconfig** - LSP configuration
- **mason.nvim** - LSP installer
- **nvim-cmp** - Completion engine
- **nvim-treesitter** - Syntax highlighting
- **telescope.nvim** - Fuzzy finder
- **neo-tree.nvim** - File explorer
- **gitsigns.nvim** - Git signs
- **toggleterm.nvim** - Terminal
- **conform.nvim** - Formatting
- **nvim-lint** - Linting
- **trouble.nvim** - Diagnostics
- **which-key.nvim** - Keybinding help
- **noice.nvim** - UI enhancement

### CTF/Security Aliases
| Alias | Command |
|-------|---------|
| `ms` | `$HOME/scripts/BASH/combo.sh` |
| `vpn` | `$HOME/scripts/BASH/vpnc.sh` |
| `rs` | `$HOME/scripts/BASH/rustscan.sh` |
| `gs` | `$HOME/scripts/BASH/gobuster.sh` |
| `ass` | `$HOME/scripts/BASH/asm2.sh` |
| `hmv` | `$HOME/scripts/BASH/hmv.sh` |
| `htbdir <name>` | Create & cd to HTB machine dir |
| `whatsmyip` | Show internal & external IP |
| `extract <file>` | Extract any archive |

## Customization

### Local Overrides (not tracked)
Create `~/.bashrc.local` or `~/.zshrc.local` for machine-specific config.

### Per-project Starship
Add `.config/starship.toml` to any git repo for project-specific prompt.

## Requirements

- **Shell**: bash 4.4+ or zsh 5.8+
- **Neovim**: 0.9+
- **Starship**: Latest
- **Git**: 2.30+

Optional but recommended:
- Nerd Font (MesloLGS NF, JetBrainsMono NF, etc.)
- `eza`, `bat`, `fd`, `ripgrep`, `zoxide`, `fzf`

## License

MIT - Feel free to use and modify.