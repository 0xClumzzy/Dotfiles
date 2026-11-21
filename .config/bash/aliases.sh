#!/usr/bin/env bash
# Aliases - shared between bash and zsh

# ---- Safety / verbose ----
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias rm='rm -i'

# ---- Navigation ----
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'
alias bd='cd "$OLDPWD"'

# ---- Listing (ls) ----
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
    alias lta='eza -la --tree --level=2 --icons'
    alias l='eza -l --icons --group-directories-first'
else
    alias ls='ls --color=auto -F'
    alias la='ls -Alh'
    alias ll='ls -lFh'
    alias lt='ls -ltrh'
    alias l='ls -lFh'
fi

alias lx='ls -lXBh'       # sort by extension
alias lk='ls -lSrh'       # sort by size
alias lc='ls -ltcrh'      # sort by change time
alias lu='ls -lturh'      # sort by access time
alias lr='ls -lRh'        # recursive
alias lm='ls -alh | more' # pipe through more
alias lw='ls -xAh'        # wide listing
alias labc='ls -lap'      # alphabetical
alias lf="ls -l | grep -Ev '^d'"  # files only
alias ldir="ls -l | grep -E '^d'" # directories only

# ---- System / process ----
alias ps='ps auxf'
alias ping='ping -c 5'
alias topcpu='/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -15'
alias topmem='/bin/ps -eo pmem,pid,user,args | sort -k 1 -r | head -15'

# ---- Search / find ----
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias f='find . -type f | grep '
alias fd='find . -type d | grep '

# ---- History ----
alias h='history | grep '
alias hgrep='history | grep '

# ---- Archive ----
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# ---- Disk / space ----
alias df='df -h'
alias du='du -h'
alias diskspace='du -S | sort -n -r | more'
alias folders='du -h --max-depth=1 | sort -hr'
alias mountedinfo='df -hT'

if command -v ncdu >/dev/null 2>&1; then
    alias ncdu='ncdu --color dark'
fi

# ---- Network ----
if command -v ss >/dev/null 2>&1; then
    alias openports='ss -tulpen'
    alias listening='ss -tuln'
elif command -v netstat >/dev/null 2>&1; then
    alias openports='netstat -nape --inet'
    alias listening='netstat -tuln'
fi

alias myip='curl -s https://ifconfig.me && echo'
alias localip="ip -o -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if(\$i==\"src\") print \$(i+1)}'"

# ---- Package management (Arch/Manjaro) ----
alias fuckup='sudo pacman -Rns --noconfirm'
alias lookfor='pacman -Ss'
alias need='sudo pacman -Sy --noconfirm'
alias get='sudo pacman -Sy --noconfirm'
alias update='sudo pacman -Syu --noconfirm'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "No orphans"'
alias pacman-clean='sudo pacman -Sc --noconfirm'

if command -v yay >/dev/null 2>&1; then
    alias ysearch='yay -Ss'
    alias yget='yay -S'
    alias yupdate='yay -Syu --noconfirm'
fi

if command -v paru >/dev/null 2>&1; then
    alias psearch='paru -Ss --noconfirm'
    alias pget='paru -S --noconfirm'
    alias pupdate='paru -Syu --noconfirm'
fi

# ---- Systemd ----
alias status='sudo systemctl status'
alias enable='sudo systemctl enable --now'
alias start='sudo systemctl start'
alias stop='sudo systemctl stop'
alias restart='sudo systemctl restart'
alias disable='sudo systemctl disable'
alias daemon-reload='sudo systemctl daemon-reload'
alias network='sudo systemctl start --now NetworkManager'
alias logs='journalctl -f'
alias logs-error='journalctl -p err -f'

# ---- Reboot / power ----
alias rebootsafe='sudo reboot'
alias rebootforce='sudo reboot -f'
alias shutdown='sudo shutdown now'

# ---- Docker ----
alias docker-clean='docker container prune -f && docker image prune -f && docker network prune -f && docker volume prune -f'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'
alias dexec='docker exec -it'

# ---- Git ----
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gca='git commit -am'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline -20'
alias gla='git log --oneline --all --graph -30'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gba='git branch -a'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git stash'
alias gstp='git stash pop'
alias gf='git fetch'
alias grh='git reset --hard'
alias grs='git reset --soft'
alias gm='git merge'
alias grb='git rebase'
alias gclean='git clean -fd'

# Quick commit
gcom() {
    if [ -z "$1" ]; then
        echo "Usage: gcom \"commit message\""
        return 1
    fi
    git add -A && git commit -m "$1"
}
lazyg() {
    if [ -z "$1" ]; then
        echo "Usage: lazyg \"commit message\""
        return 1
    fi
    git add -A && git commit -m "$1" && git push
}

# ---- Python venv ----
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias activate='source .venv/bin/activate'
alias deactivate='deactivate'
alias venv-rm='rm -rf .venv'

# ---- CTF / Security tools ----
alias ms='bash $HOME/scripts/BASH/combo.sh'
alias vpn='bash $HOME/scripts/BASH/vpnc.sh'
alias rs='bash $HOME/scripts/BASH/rustscan.sh'
alias gs='bash $HOME/scripts/BASH/gobuster.sh'
alias ass='bash $HOME/scripts/BASH/asm2.sh'
alias hmv='bash $HOME/scripts/BASH/hmv.sh'
alias hmvc='bash $HOME/scripts/BASH/hmvc.sh'

# ---- Misc ----
alias c='clear'
alias x='exit'
alias r='reboot'
alias fucking='sudo'
alias please='sudo'
alias cls='clear'
alias da='date "+%Y-%m-%d %A %T %Z"'
alias sha1='openssl sha1'
alias path='echo -e ${PATH//:/\\n}'

# Editor shortcuts
if command -v nvim >/dev/null 2>&1; then
    alias vim='nvim'
    alias vi='nvim'
    alias vis='nvim "+set si"'
    alias e='nvim ~/.bashrc'
fi

alias hosts='sudo $EDITOR /etc/hosts'

# Reload shell
alias reload='source ~/.bashrc && echo "Reloaded ~/.bashrc"'
alias src='source ~/.bashrc'

# Tree
if command -v tree >/dev/null 2>&1; then
    alias tree='tree -CAhF --dirsfirst'
    alias treed='tree -CAFd'
fi

# less
alias less='less -R'

# Quick edit configs
alias zshrc='$EDITOR ~/.zshrc'
alias bashrc='$EDITOR ~/.bashrc'
alias nvimrc='$EDITOR ~/.config/nvim/init.lua'
alias starshipcfg='$EDITOR ~/.config/starship.toml'

# ---- Functions ----

# Extract any archive
extract() {
    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case $archive in
                *.tar.bz2) tar xvjf "$archive" ;;
                *.tar.gz)  tar xvzf "$archive" ;;
                *.bz2)     bunzip2 "$archive" ;;
                *.rar)     unrar x "$archive" ;;
                *.gz)      gunzip "$archive" ;;
                *.tar)     tar xvf "$archive" ;;
                *.tbz2)    tar xvjf "$archive" ;;
                *.tgz)     tar xvzf "$archive" ;;
                *.zip)     unzip "$archive" ;;
                *.Z)       uncompress "$archive" ;;
                *.7z)      7z x "$archive" ;;
                *)         echo "don't know how to extract '$archive'..." ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# Search text in files
ftext() {
    grep -iIHrn --color=always "$1" . | less -R
}

# Copy with progress (requires strace)
cpp() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: cpp SOURCE DESTINATION"
        return 2
    fi
    if ! command -v strace >/dev/null 2>&1; then
        echo "cpp requires strace."
        return 1
    fi
    strace -q -ewrite cp -- "$1" "$2" 2>&1 |
    awk '{
        count += $NF
        if (count % 10 == 0 && total_size > 0) {
            percent = int(count / total_size * 100)
            if (percent > 100) percent = 100
            printf "%3d%% [", percent
            for (i=0;i<=percent;i++) printf "="
            printf ">"
            for (i=percent;i<100;i++) printf " "
            printf "]\r"
        }
    }
    END { print "" }' total_size="$(stat -c '%s' "$1")" count=0
}

# Copy/move and go to directory
cpg() {
    if [ -d "$2" ]; then
        cp "$1" "$2" && cd "$2"
    else
        cp "$1" "$2"
    fi
}
mvg() {
    if [ -d "$2" ]; then
        mv "$1" "$2" && cd "$2"
    else
        mv "$1" "$2"
    fi
}

# Make directory and cd
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# HTB directory
htbdir() {
    mkdir -p "$HOME/ctfs/htb/$1" && cd "$HOME/ctfs/htb/$1"
}

# Clone and cd
clone() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Go up N directories
up() {
    local d="" limit=${1:-1}
    if ! [[ $limit =~ ^[0-9]+$ ]]; then
        echo "Usage: up [number]"
        return 2
    fi
    for ((i=1; i<=limit; i++)); do
        d=$d/..
    done
    cd "${d#/}" || return
}

# Count files
countfiles() {
    for t in files links directories; do
        echo "$(find . -type "${t:0:1}" | wc -l) $t"
    done 2>/dev/null
}

# IP lookup
whatsmyip() {
    echo -n "Internal IP: "
    if command -v ip >/dev/null 2>&1; then
        ip -o -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}'
    elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig | awk '/inet / && $2 != "127.0.0.1" {print $2; exit}'
    else
        echo "unknown"
    fi
    echo -n "External IP: "
    if command -v curl >/dev/null 2>&1; then
        curl -4fsS --max-time 5 https://ifconfig.me || echo "unknown"
    else
        echo "curl not installed"
    fi
}
alias whatismyip='whatsmyip'

# Sudo edit
sedit() {
    sudo "${SUDO_EDITOR:-${EDITOR:-vi}}" "$@"
}

# Click to paste (Wayland/X11)
clickpaste() {
    sleep "${1:-3}"
    if command -v wl-paste >/dev/null 2>&1 && command -v wtype >/dev/null 2>&1; then
        wl-paste | wtype -
    elif command -v xclip >/dev/null 2>&1 && command -v xdotool >/dev/null 2>&1; then
        xdotool type "$(xclip -o -selection clipboard)"
    else
        echo "clickpaste requires wl-paste+wtype on Wayland or xclip+xdotool on X11."
        return 1
    fi
}

# Distro detection
distribution() {
    local dtype="unknown"
    if [ -r /etc/os-release ]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        case $ID in
            fedora|rhel|centos)           dtype="redhat" ;;
            sles|opensuse*)               dtype="suse" ;;
            ubuntu|debian)                dtype="debian" ;;
            gentoo)                       dtype="gentoo" ;;
            arch|manjaro|endeavouros)     dtype="arch" ;;
            slackware)                    dtype="slackware" ;;
            *)
                if [ -n "$ID_LIKE" ]; then
                    case $ID_LIKE in
                        *fedora*|*rhel*|*centos*) dtype="redhat" ;;
                        *sles*|*opensuse*)        dtype="suse" ;;
                        *ubuntu*|*debian*)        dtype="debian" ;;
                        *gentoo*)                 dtype="gentoo" ;;
                        *arch*)                   dtype="arch" ;;
                        *slackware*)              dtype="slackware" ;;
                    esac
                fi ;;
        esac
    fi
    echo "$dtype"
}

ver() {
    local dtype
    dtype=$(distribution)
    case $dtype in
        redhat)   [ -s /etc/redhat-release ] && cat /etc/redhat-release || cat /etc/issue; uname -a ;;
        suse)     cat /etc/SuSE-release ;;
        debian)   lsb_release -a ;;
        gentoo)   cat /etc/gentoo-release ;;
        arch)     cat /etc/os-release ;;
        slackware) cat /etc/slackware-version ;;
        *)
            if [ -s /etc/issue ]; then cat /etc/issue
            else echo "Error: Unknown distribution"; exit 1
            fi ;;
    esac
}

# Install common tools based on distro
install_tools() {
    local dtype
    dtype=$(distribution)
    case $dtype in
        redhat)
            if command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y multitail tree zoxide trash-cli fzf bash-completion # fastfetch eza bat fd-find ripgrep
            else
                sudo yum install -y multitail tree zoxide trash-cli fzf bash-completion # fastfetch
            fi ;;
        suse)    sudo zypper install -y multitail tree zoxide trash-cli fzf bash-completion # fastfetch ;;
        debian)  sudo apt-get update && sudo apt-get install -y multitail tree zoxide trash-cli fzf bash-completion # fastfetch eza bat fd-find ripgrep ;;
        arch)    sudo pacman -S --needed multitail tree zoxide trash-cli fzf bash-completion # fastfetch eza bat fd ripgrep ;;
        slackware) echo "No install support for Slackware" ;;
        *)       echo "Unknown distribution" ;;
    esac
}

# Trim whitespace
trim() {
    local var=$*
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

# Get last 2 dirs of pwd
pwdtail() {
    pwd | awk -F/ '{nlast = NF -1; print $nlast"/"$NF}'
}

# ---- Tool installers ----

# thefuck
if ! command -v thefuck >/dev/null 2>&1; then
    if command -v pipx >/dev/null 2>&1; then
        pipx install thefuck
    elif command -v pip >/dev/null 2>&1; then
        pip install thefuck --user
    fi
fi

# Docker clean function
docker-clean() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "docker is not installed."
        return 1
    fi
    docker container prune -f
    docker image prune -f
    docker network prune -f
    docker volume prune -f
}

# GEF for GDB
addGef() {
    wget -O ~/.gdbinit-gef.py -q https://gef.blah.cat/py
    echo "source ~/.gdbinit-gef.py" >> ~/.gdbinit
}

# Python security tools (using uv/pipx where possible)
waf() {
    if command -v wafw00f >/dev/null 2>&1; then
        wafw00f "$@"
    else
        python3 -m venv ~/.venvs/wafw00f 2>/dev/null
        ~/.venvs/wafw00f/bin/pip install wafw00f 2>/dev/null
        ~/.venvs/wafw00f/bin/wafw00f "$@"
    fi
}

# Fuzzing stack installer
fuzzing() {
    set -euo pipefail
    sudo pacman -Syu --needed --noconfirm go git base-devel
    if ! command -v paru >/dev/null 2>&1; then
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        cd /tmp/paru && makepkg -si --noconfirm
    fi
    paru -S --needed --noconfirm python-pipx
    pipx ensurepath
    sudo pipx ensurepath --global
    go install github.com/ffuf/ffuf/v2@latest
    go install github.com/OJ/gobuster/v3@latest
    curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh | bash -s "$HOME/.local/bin"
    pipx install git+https://github.com/WebFuzzForge/wenum
    pipx runpip wenum install setuptools
}

# Paru installer
paruinstall() {
    set -euo pipefail
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si
}