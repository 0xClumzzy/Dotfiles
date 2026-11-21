#!/usr/bin/env bash
# PATH management - sourced by both bash and zsh

# Helper to prepend to PATH if directory exists and not already present
path_prepend() {
    for p in "$@"; do
        if [ -d "$p" ]; then
            case ":$PATH:" in
                *":$p:"*) ;;
                *) PATH="$p:$PATH" ;;
            esac
        fi
    done
}

# Helper to append to PATH if directory exists and not already present
path_append() {
    for p in "$@"; do
        if [ -d "$p" ]; then
            case ":$PATH:" in
                *":$p:"*) ;;
                *) PATH="$PATH:$p" ;;
            esac
        fi
    done
}

# ---- Prepend (higher priority) ----
path_prepend \
    "$HOME/.local/bin" \
    "/home/linuxbrew/.linuxbrew/bin" \
    "/home/linuxbrew/.linuxbrew/sbin" \
    "$HOME/.linuxbrew/bin" \
    "$HOME/.linuxbrew/sbin" \
    "$HOME/.local/share/pnpm" \
    "$HOME/.npm-global/bin" \
    "$HOME/.yarn/bin" \
    "$HOME/.yarn/global/node_modules/.bin" \
    "$HOME/go/bin" \
    "$HOME/.deno/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.bun/bin" \
    "$HOME/.opencode/bin" \
    "$HOME/scripts/BASH" \
    "/var/lib/flatpak/exports/bin" \
    "$HOME/.local/share/flatpak/exports/bin" \
    "$HOME/.mimicode/bin"

# ---- PNPM ----
export PNPM_HOME="$HOME/.local/share/pnpm"
path_prepend "$PNPM_HOME/bin"

# ---- Rust/cargo ----
if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
fi

# ---- Bun ----
if [ -s "$HOME/.bun/_bun" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.bun/_bun"
fi

# Export the modified PATH
export PATH