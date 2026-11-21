#!/usr/bin/env bash
# Interactive Nerd Font installer with preview
# Supports: icursive, MesloLGS, JetBrainsMono, FiraCode, Hack, SourceCodePro, etc.

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

FONT_DIR="$HOME/.local/share/fonts"
CACHE_DIR="$HOME/.cache/nerd-fonts"
GITHUB_API="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
ICURSIVE_REPO="https://github.com/thlineric/icursive-nerd-font"

# Font configurations: name|github_path|display_name|has_italic|description
FONTS=(
    "MesloLGS|Meslo/SD/MesloLGS|MesloLGS Nerd Font|true|Classic Meslo with ligatures, great for terminals"
    "JetBrainsMono|JetBrainsMono|JetBrains Mono Nerd Font|true|Popular dev font, clean with great italics"
    "FiraCode|FiraCode|FiraCode Nerd Font|true|Famous for ligatures, clean and readable"
    "Hack|Hack|Hack Nerd Font|true|Designed for source code, very legible"
    "SourceCodePro|SourceCodePro|Source Code Pro Nerd Font|true|Adobe's monospace, professional look"
    "CascadiaCode|CascadiaCode|Cascadia Code Nerd Font|true|Microsoft's terminal font with ligatures"
    "UbuntuMono|UbuntuMono|Ubuntu Mono Nerd Font|true|Ubuntu's monospace, warm and readable"
    "Inconsolata|Inconsolata|Inconsolata Nerd Font|true|Humanist monospace, great for long coding"
    "VictorMono|VictorMono|Victor Mono Nerd Font|true|Unique cursive italics, very distinctive"
    "Iosevka|Iosevka|Iosevka Nerd Font|true|Highly customizable, narrow for more code"
    "Mononoki|Mononoki|Mononoki Nerd Font|true|Clean with programming ligatures"
    "Cousine|Cousine|Cousine Nerd Font|true|Google's monospace, metric-compatible with Courier"
)

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_prompt() { echo -e "${CYAN}[SELECT]${NC} $*"; }

# Check dependencies
check_deps() {
    local missing=()
    for cmd in curl wget fc-cache unzip tar; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing: ${missing[*]}"
        log_info "Install: sudo apt install curl wget fontconfig unzip tar (or equivalent)"
        return 1
    fi
    return 0
}

# Get latest release version
get_latest_version() {
    curl -s "$GITHUB_API" | grep -oP '"tag_name": "\K[^"]+' | head -1
}

# Download and extract font
download_font() {
    local font_key="$1"
    local version="$2"
    local repo_path="$3"
    local font_dir="$FONT_DIR/$font_key"
    
    mkdir -p "$font_dir"
    mkdir -p "$CACHE_DIR"
    
    local archive_name="${font_key}.zip"
    local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${archive_name}"
    local cache_file="$CACHE_DIR/${version}-${archive_name}"
    
    log_info "Downloading $font_key..."
    
    if [ -f "$cache_file" ]; then
        log_info "Using cached: $cache_file"
    else
        if ! wget -q --show-progress -O "$cache_file" "$download_url"; then
            log_error "Failed to download $font_key"
            return 1
        fi
    fi
    
    log_info "Extracting $font_key..."
    if ! unzip -qo "$cache_file" -d "$font_dir"; then
        log_error "Failed to extract $font_key"
        return 1
    fi
    
    # Remove non-font files
    find "$font_dir" -type f ! -name "*.ttf" ! -name "*.otf" -delete
    
    log_success "Installed $font_key to $font_dir"
    return 0
}

# Install icursive font (separate repo - thlineric/icursive-nerd-font)
install_icursive() {
    local font_dir="$FONT_DIR/icursive"
    local base_url="https://raw.githubusercontent.com/thlineric/icursive-nerd-font/master"
    
    mkdir -p "$font_dir"
    mkdir -p "$CACHE_DIR"
    
    log_info "Downloading icursive-nerd-font (patched fonts with cursive italics)..."
    
    # Font variants available in the repo
    local variants=(
        "Meslo iCursive S12"
        "Fira Code iCursive S12"
        "Hack iCursive S12"
        "JetBrains Mono iCursive"
        "Fantasque iCursive Dk"
        "Fantasque iCursive Op"
        "InconsolataGo iCursive Pb"
        "InconsolataLGC iCursive S12"
        "Roboto Mono iCursive Pt"
        "Source Code Pro iCursive S12"
    )
    
    local downloaded=0
    for variant in "${variants[@]}"; do
        local variant_dir=$(echo "$variant" | sed 's/ /%20/g')
        local font_files=("Regular" "Bold" "Italic" "Bold Italic")
        
        for style in "${font_files[@]}"; do
            local file_name="${variant} ${style}.ttf"
            local encoded_name=$(echo "$file_name" | sed 's/ /%20/g')
            local url="${base_url}/${variant_dir}/${encoded_name}"
            local dest_file="$font_dir/${file_name}"
            
            if [ -f "$dest_file" ]; then
                continue
            fi
            
            if wget -q --show-progress -O "$dest_file" "$url" 2>/dev/null; then
                ((downloaded++))
            else
                # Some variants may not have all styles, that's OK
                rm -f "$dest_file"
            fi
        done
    done
    
    if [ $downloaded -gt 0 ]; then
        log_success "Downloaded $downloaded icursive font files to $font_dir"
        return 0
    else
        log_error "Failed to download any icursive fonts"
        return 1
    fi
}

# Show font preview in terminal
show_preview() {
    local font_name="$1"
    
    echo -e "\n${BOLD}=== Preview: $font_name ===${NC}"
    echo
    
    # Test strings
    local test_strings=(
        "The quick brown fox jumps over the lazy dog"
        "0123456789  \`~!@#\$%^&*()_+-=[]{}|;':\",./<>?"
        "fn main() { println!(\"Hello, World!\"); }"
        "const config = { enabled: true, items: [1, 2, 3] };"
        "def hello():\n    return \"Hello, World!\""
        "git commit -m \"feat: add amazing feature\""
        "█▓▒░ Box drawing: ┌─┐ │ │ └─┘"
        "╔══════════════════════════════╗"
        "║  Powerline:        ║"
        "║  Nerd icons: 󰀠 󰀡 󰀢 󰀣 󰀤  ║"
        "╚══════════════════════════════╝"
    )
    
    for str in "${test_strings[@]}"; do
        echo "$str"
    done
    
    # Italic test if font supports it
    echo
    echo -e "\e[3mItalic test: The quick brown fox jumps over the lazy dog\e[0m"
    echo -e "\e[3mCode italics: function() { return true; }\e[0m"
    echo
}

# List installed fonts
list_installed() {
    log_info "Currently installed Nerd Font families:"
    
    # Get unique font families (properly parse fc-list output)
    local families=$(fc-list | grep -i "nerd\|meslo\|jetbrains\|fira\|hack\|sourcecode\|cascadia\|ubuntu\|inconsolata\|victor\|iosevka\|mononoki\|cousine\|icursive" | \
        sed -E 's/^[^:]+: ([^,]+)(,.*)?$/\1/' | cut -d: -f1 | sort -u)
    
    if [ -z "$families" ]; then
        echo "  (none found)"
    else
        echo "$families" | while read -r font; do
            # Skip individual file paths and style variants
            [[ "$font" == *.ttf ]] || [[ "$font" == *.otf ]] && continue
            [[ "$font" == *:style=* ]] && continue
            echo "  • $font"
        done
    fi
    echo
}

# Interactive font selection
select_fonts() {
    local selected=()
    
    echo -e "${BOLD}${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${MAGENTA}║         Nerd Font Installer - Select Fonts                ║${NC}"
    echo -e "${BOLD}${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
    
    list_installed
    
    echo -e "${BOLD}Available Fonts:${NC}"
    echo
    
    # Show icursive first (special)
    echo -e "${CYAN}0) icursive-nerd-font${NC} - Cursive italics, unique style (thlineric/icursive-nerd-font)"
    echo
    
    # Show regular fonts
    local i=1
    for font_entry in "${FONTS[@]}"; do
        IFS='|' read -r key path name italic desc <<< "$font_entry"
        local italic_mark=""
        [ "$italic" = "true" ] && italic_mark=" ${YELLOW}[italic]${NC}"
        echo -e "${CYAN}$i)${NC} $name$italic_mark"
        echo -e "    ${desc}"
        ((i++))
    done
    
    echo
    echo -e "${CYAN}a)${NC} Install ALL fonts"
    echo -e "${CYAN}q)${NC} Quit"
    echo
    
    while true; do
        log_prompt "Select fonts (comma-separated numbers, e.g., 1,3,5): "
        read -r input
        
        case "$input" in
            q|Q) return 1 ;;
            a|A) 
                selected=("icursive" "${FONTS[@]}")
                break
                ;;
            *)
                IFS=',' read -ra choices <<< "$input"
                valid=true
                for choice in "${choices[@]}"; do
                    choice=$(echo "$choice" | xargs)
                    if [ "$choice" = "0" ]; then
                        selected+=("icursive")
                    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#FONTS[@]} ]; then
                        selected+=("${FONTS[$((choice-1))]}")
                    else
                        log_error "Invalid choice: $choice"
                        valid=false
                    fi
                done
                [ "$valid" = true ] && break
                ;;
        esac
    done
    
    echo
    log_info "Selected fonts:"
    for sel in "${selected[@]}"; do
        if [ "$sel" = "icursive" ]; then
            echo "  • icursive-nerd-font"
        else
            IFS='|' read -r key path name italic desc <<< "$sel"
            echo "  • $name"
        fi
    done
    echo
    
    read -r -p "Proceed with installation? [Y/n] " confirm
    [[ "$confirm" =~ ^[Nn]$ ]] && return 1
    
    SELECTED_FONTS=("${selected[@]}")
    return 0
}

# Preview selected font
preview_font() {
    local font_entry="$1"
    
    if [ "$font_entry" = "icursive" ]; then
        show_preview "icursive-nerd-font (cursive italics)"
    else
        IFS='|' read -r key path name italic desc <<< "$font_entry"
        show_preview "$name"
    fi
    
    read -r -p "Press Enter to continue..."
}

# Main installation
install_selected() {
    local version=$(get_latest_version)
    log_info "Using Nerd Fonts version: $version"
    
    mkdir -p "$FONT_DIR"
    
    local failed=()
    local success=()
    
    for font_entry in "${SELECTED_FONTS[@]}"; do
        if [ "$font_entry" = "icursive" ]; then
            if install_icursive; then
                success+=("icursive-nerd-font")
            else
                failed+=("icursive-nerd-font")
            fi
        else
            IFS='|' read -r key path name italic desc <<< "$font_entry"
            if download_font "$key" "$version" "$path"; then
                success+=("$name")
            else
                failed+=("$name")
            fi
        fi
    done
    
    # Refresh font cache
    log_info "Refreshing font cache..."
    fc-cache -f "$FONT_DIR"
    
    echo
    log_success "Installation complete!"
    echo
    
    if [ ${#success[@]} -gt 0 ]; then
        log_success "Successfully installed:"
        for font in "${success[@]}"; do
            echo "  ✓ $font"
        done
    fi
    
    if [ ${#failed[@]} -gt 0 ]; then
        log_error "Failed to install:"
        for font in "${failed[@]}"; do
            echo "  ✗ $font"
        done
    fi
    
    echo
    log_info "To use in your terminal:"
    echo "  1. Restart your terminal"
    echo "  2. Set font to one of the installed fonts"
    echo "  3. For cursive italics, enable italic in terminal settings"
}

# Update existing fonts
update_fonts() {
    log_info "Checking for font updates..."
    
    local version=$(get_latest_version)
    log_info "Latest version: $version"
    
    # Find installed nerd font families
    local installed_families=()
    while IFS= read -r font; do
        installed_families+=("$font")
    done < <(fc-list | grep -i "nerd" | sed -E 's/^[^:]+: ([^,]+)(,.*)?$/\1/' | cut -d: -f1 | sort -u)
    
    # Filter out individual files and style variants
    local filtered=()
    for font in "${installed_families[@]}"; do
        [[ "$font" == *.ttf ]] || [[ "$font" == *.otf ]] && continue
        [[ "$font" == *:style=* ]] && continue
        filtered+=("$font")
    done
    installed_families=("${filtered[@]}")
    
    if [ ${#installed_families[@]} -eq 0 ]; then
        log_warn "No Nerd Fonts found to update"
        return 0
    fi
    
    log_info "Found installed font families:"
    for font in "${installed_families[@]}"; do
        echo "  • $font"
    done
    echo
    
    read -r -p "Reinstall all with latest version? [y/N] " confirm
    [[ ! "$confirm" =~ ^[Yy]$ ]] && return 0
    
    # Reinstall all standard fonts
    for font_entry in "${FONTS[@]}"; do
        IFS='|' read -r key path name italic desc <<< "$font_entry"
        download_font "$key" "$version" "$path" || true
    done
    
    # Update icursive if present
    if fc-list | grep -qi "icursive"; then
        install_icursive || true
    fi
    
    fc-cache -f "$FONT_DIR"
    log_success "Font update complete"
}

# Main
main() {
    case "${1:-}" in
        --list|-l)
            list_installed
            ;;
        --update|-u)
            check_deps || exit 1
            update_fonts
            ;;
        --preview|-p)
            if [ -n "${2:-}" ]; then
                # Find font by number
                if [ "$2" = "0" ]; then
                    show_preview "icursive-nerd-font"
                elif [[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -ge 1 ] && [ "$2" -le ${#FONTS[@]} ]; then
                    IFS='|' read -r key path name italic desc <<< "${FONTS[$((2-1))]}"
                    show_preview "$name"
                else
                    log_error "Invalid font number"
                fi
            else
                log_error "Usage: $0 --preview <number>"
            fi
            ;;
        --install|-i)
            if [ -n "${2:-}" ]; then
                # Non-interactive install
                SELECTED_FONTS=()
                IFS=',' read -ra choices <<< "$2"
                for choice in "${choices[@]}"; do
                    choice=$(echo "$choice" | xargs)
                    if [ "$choice" = "0" ]; then
                        SELECTED_FONTS+=("icursive")
                    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#FONTS[@]} ]; then
                        SELECTED_FONTS+=("${FONTS[$((choice-1))]}")
                    fi
                done
                check_deps || exit 1
                install_selected
            else
                check_deps || exit 1
                if select_fonts; then
                    install_selected
                fi
            fi
            ;;
        --help|-h|"")
            echo "Usage: $0 [command] [options]"
            echo
            echo "Commands:"
            echo "  (no args)        Interactive font selector with preview"
            echo "  -i, --install    Install fonts (interactive or comma-separated list)"
            echo "  -l, --list       List currently installed Nerd Fonts"
            echo "  -u, --update     Update all installed fonts to latest version"
            echo "  -p, --preview N  Preview font by number (0 = icursive)"
            echo "  -h, --help       Show this help"
            echo
            echo "Examples:"
            echo "  $0                      # Interactive mode"
            echo "  $0 -i 1,3,5            # Install MesloLGS, FiraCode, SourceCodePro"
            echo "  $0 -i 0                # Install icursive only"
            echo "  $0 -p 2                # Preview JetBrainsMono"
            echo "  $0 -u                  # Update all fonts"
            ;;
        *)
            check_deps || exit 1
            if select_fonts; then
                install_selected
            fi
            ;;
    esac
}

main "$@"