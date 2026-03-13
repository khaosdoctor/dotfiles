#!/usr/bin/env bash
# Performs a full system upgrade across macOS and Linux distros,
# including package managers, Neovim plugins, version managers,
# and dotfiles git housekeeping.

set -uo pipefail

BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

# ── Error Collection ─────────────────────────────────────────────────

ERRORS=()

collect_error() {
    local context="$1"
    local msg="$2"
    ERRORS+=("[$context] $msg")
    err "$msg"
}

# Runs a command and collects the error if it fails
# Usage: try "context label" command arg1 arg2 ...
try() {
    local context="$1"
    shift
    if ! "$@" 2>&1; then
        collect_error "$context" "Command failed: $*"
    fi
}

print_error_summary() {
    if [ ${#ERRORS[@]} -eq 0 ]; then
        return
    fi

    echo ""
    echo -e "${RED}${BOLD}══ Errors encountered during upgrade ══${RESET}"
    for e in "${ERRORS[@]}"; do
        echo -e "  ${RED}•${RESET} $e"
    done
    echo -e "${RED}${BOLD}════════════════════════════════════════${RESET}"
}

# ── Helpers ──────────────────────────────────────────────────────────

info()  { echo -e "${GREEN}[+]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[!]${RESET} $*"; }
err()   { echo -e "${RED}[-]${RESET} $*"; }
step()  { echo -e "\n${BOLD}==> $*${RESET}"; }
skip()  { echo -e "${DIM} ·  skipping $* (not found)${RESET}"; }

has() { command -v "$1" &>/dev/null; }

# ── OS Detection ─────────────────────────────────────────────────────

OS="$(uname -s)"

detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "${ID:-unknown}"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    else
        echo "unknown"
    fi
}

# ── Dotfiles Dir Resolution ─────────────────────────────────────────

resolve_dotfiles_dir() {
    # Use $DOTFILES env var if set and valid
    if [ -n "${DOTFILES:-}" ] && [ -d "$DOTFILES" ]; then
        echo "$DOTFILES"
        return
    fi

    # Prompt the user for the path
    warn "\$DOTFILES is not set or directory doesn't exist."
    echo -n "Enter your dotfiles path (or leave empty to skip): "
    read -r user_path

    if [ -n "$user_path" ] && [ -d "$user_path" ]; then
        echo "$user_path"
    else
        echo ""
    fi
}

# ── Package Manager Upgrades ─────────────────────────────────────────

# Attempts a brew upgrade; on failure, parses which packages failed,
# retries without them, and collects per-package errors.
# Usage: brew_smart_upgrade ""            (formulae)
#        brew_smart_upgrade "--cask --greedy"  (casks)
brew_smart_upgrade() {
    local extra_flags="$1"
    local output
    local label="brew"
    [[ "$extra_flags" == *--cask* ]] && label="brew-cask"

    # shellcheck disable=SC2086
    if output="$(brew upgrade $extra_flags 2>&1)"; then
        echo "$output"
        return
    fi

    echo "$output"

    # Extract failed package names from brew output.
    # Brew error formats:
    #   "Error: Cask 'claude' definition is invalid: ..."
    #   "Error: Download failed on Cask 'claude' with message: ..."
    #   "Error: <formula>: <reason>"
    local failed_pkgs=()

    # Match: Error: Cask '<name>' or Error: Download failed on Cask '<name>'
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        failed_pkgs+=("$pkg")
    done < <(echo "$output" | sed -n "s/.*[Cc]ask '\([^']*\)'.*/\1/p" | sort -u)

    # Match: Error: <formula>: <reason> (but not lines with Cask which are already handled)
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        failed_pkgs+=("$pkg")
    done < <(echo "$output" | grep -v -i 'cask' | sed -n 's/^Error: \([^:]*\):.*/\1/p' | sort -u)

    # De-duplicate
    if [ ${#failed_pkgs[@]} -gt 0 ]; then
        local dedup=()
        while IFS= read -r p; do dedup+=("$p"); done < <(printf '%s\n' "${failed_pkgs[@]}" | sort -u)
        failed_pkgs=("${dedup[@]}")
    fi

    if [ ${#failed_pkgs[@]} -eq 0 ]; then
        # Could not parse individual failures — just collect the whole error
        collect_error "$label" "brew upgrade failed (could not determine which packages)"
        return
    fi

    # Collect errors for the failed packages
    for pkg in "${failed_pkgs[@]}"; do
        collect_error "$label" "Failed to upgrade: $pkg"
    done

    # Get all outdated packages and retry without the failed ones
    local outdated=()
    local is_cask=false
    [[ "$extra_flags" == *--cask* ]] && is_cask=true

    if $is_cask; then
        while IFS= read -r pkg; do
            [ -z "$pkg" ] && continue
            outdated+=("$pkg")
        done < <(brew outdated --cask -q 2>/dev/null)
    else
        while IFS= read -r pkg; do
            [ -z "$pkg" ] && continue
            outdated+=("$pkg")
        done < <(brew outdated --formula -q 2>/dev/null)
    fi

    # Filter out failed packages and retry the rest
    if [ ${#outdated[@]} -eq 0 ]; then
        return
    fi

    local retry_pkgs=()
    for pkg in "${outdated[@]}"; do
        local skip_it=false
        for bad in "${failed_pkgs[@]}"; do
            if [[ "$pkg" == "$bad" ]]; then
                skip_it=true
                break
            fi
        done
        $skip_it || retry_pkgs+=("$pkg")
    done

    if [ ${#retry_pkgs[@]} -gt 0 ]; then
        info "Retrying upgrade for remaining ${#retry_pkgs[@]} package(s), skipping: ${failed_pkgs[*]}"
        for pkg in "${retry_pkgs[@]}"; do
            # shellcheck disable=SC2086
            if ! brew upgrade $extra_flags "$pkg" 2>&1; then
                collect_error "$label" "Failed to upgrade on retry: $pkg"
            fi
        done
    fi
}

upgrade_macos() {
    step "macOS system upgrade"

    if has brew; then
        info "Updating Homebrew..."
        try "brew" brew update

        info "Upgrading formulae..."
        brew_smart_upgrade ""

        info "Upgrading casks..."
        brew_smart_upgrade "--cask --greedy"

        info "Cleaning up..."
        try "brew-cleanup" brew cleanup --prune=all

        # Re-dump Brewfile so dotfiles stay in sync
        if [ -f "$HOME/Brewfile" ]; then
            info "Dumping updated Brewfile..."
            if ! brew bundle dump -f -a --no-upgrade --file=- >"$HOME/Brewfile" 2>&1; then
                collect_error "brew-bundle" "Failed to dump Brewfile"
            fi
        fi
    else
        skip "brew"
    fi

    if has mas; then
        info "Upgrading App Store apps..."
        try "mas" mas upgrade
    else
        skip "mas"
    fi

    if has softwareupdate; then
        info "Checking for macOS software updates..."
        softwareupdate --list 2>&1 | grep -q "No new software available" \
            && info "macOS is up to date." \
            || try "softwareupdate" softwareupdate --install --all --agree-to-license
    fi
}

upgrade_linux() {
    local distro
    distro="$(detect_linux_distro)"
    step "Linux system upgrade (distro: ${distro})"

    case "$distro" in
        arch|endeavouros|manjaro)
            if has paru; then
                info "Upgrading with paru..."
                try "paru" paru -Syu --noconfirm
            elif has yay; then
                info "Upgrading with yay..."
                try "yay" yay -Syu --noconfirm
            elif has pacman; then
                info "Upgrading with pacman..."
                try "pacman" sudo pacman -Syu --noconfirm
            else
                skip "pacman/yay/paru"
            fi
            ;;
        ubuntu|debian|pop|linuxmint|elementary)
            if has apt; then
                info "Upgrading with apt..."
                try "apt-update" sudo apt update
                try "apt-upgrade" sudo apt upgrade -y
                try "apt-autoremove" sudo apt autoremove -y
            else
                skip "apt"
            fi
            ;;
        fedora)
            if has dnf; then
                info "Upgrading with dnf..."
                try "dnf" sudo dnf upgrade -y --refresh
            else
                skip "dnf"
            fi
            ;;
        opensuse*|sles)
            if has zypper; then
                info "Upgrading with zypper..."
                try "zypper-refresh" sudo zypper refresh
                try "zypper-update" sudo zypper update -y
            else
                skip "zypper"
            fi
            ;;
        alpine)
            if has apk; then
                info "Upgrading with apk..."
                try "apk-update" sudo apk update
                try "apk-upgrade" sudo apk upgrade
            else
                skip "apk"
            fi
            ;;
        nixos|nix)
            if has nix-channel; then
                info "Upgrading with nix..."
                try "nix-channel" nix-channel --update
                try "nix-env" nix-env --upgrade
            else
                skip "nix"
            fi
            ;;
        void)
            if has xbps-install; then
                info "Upgrading with xbps..."
                try "xbps" sudo xbps-install -Su
            else
                skip "xbps"
            fi
            ;;
        *)
            warn "Unknown distro '${distro}' — skipping system packages."
            ;;
    esac

    # Snap / Flatpak if present
    if has snap; then
        info "Upgrading snaps..."
        try "snap" sudo snap refresh
    fi
    if has flatpak; then
        info "Upgrading flatpaks..."
        try "flatpak" flatpak update -y
    fi
}

# ── Neovim / LazyVim ────────────────────────────────────────────────

upgrade_lazyvim() {
    step "Neovim plugin sync"

    if ! has nvim; then
        skip "nvim"
        return
    fi

    if [ ! -f "$HOME/.config/nvim/lazyvim.json" ]; then
        skip "lazyvim config"
        return
    fi

    info "Syncing LazyVim plugins..."
    if ! nvim --headless -c "Lazy! sync" -c "qa" 2>&1; then
        collect_error "lazyvim" "LazyVim sync failed"
    else
        info "LazyVim sync complete."
    fi
}

# ── Version Managers ─────────────────────────────────────────────────

upgrade_version_managers() {
    step "Version manager upgrades"
    local found=false

    # mise (primary in this setup)
    if has mise; then
        found=true
        info "Upgrading mise and tool versions..."
        if ! mise self-update --yes 2>/dev/null; then
            collect_error "mise" "mise self-update failed (may be managed by a package manager)"
        fi
        if ! mise upgrade --yes 2>/dev/null; then
            if ! mise install 2>&1; then
                collect_error "mise" "mise upgrade/install failed"
            fi
        fi
        mise prune --yes 2>/dev/null || true
    fi

    # asdf
    if has asdf; then
        found=true
        info "Upgrading asdf plugins and tool versions..."
        if ! asdf plugin update --all 2>&1; then
            collect_error "asdf" "asdf plugin update failed"
        fi
        if ! asdf install 2>&1; then
            collect_error "asdf" "asdf install failed"
        fi
    fi

    # nvm
    if [ -d "${NVM_DIR:-$HOME/.nvm}" ] && [ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]; then
        found=true
        info "Upgrading nvm node to latest LTS..."
        # shellcheck disable=SC1091
        . "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
        if ! nvm install --lts --reinstall-packages-from=current 2>&1; then
            collect_error "nvm" "nvm LTS upgrade failed"
        fi
    fi

    # rustup
    if has rustup; then
        found=true
        info "Upgrading Rust toolchain..."
        try "rustup" rustup update
    fi

    if [ "$found" = false ]; then
        skip "version managers (mise/asdf/nvm/rustup)"
    fi
}

# ── Dotfiles Git Housekeeping ────────────────────────────────────────

commit_dotfiles() {
    step "Dotfiles git housekeeping"

    local dotdir
    dotdir="$(resolve_dotfiles_dir)"

    if [ -z "$dotdir" ]; then
        warn "No dotfiles directory — skipping."
        return
    fi

    if [ ! -d "$dotdir/.git" ]; then
        warn "$dotdir is not a git repo — skipping."
        return
    fi

    cd "$dotdir" || return

    # Check for any changes at all
    if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
        info "Dotfiles repo is clean — nothing to commit."
        return
    fi

    info "Changes detected in dotfiles repo:"
    git status --short

    # Separate lockfile changes from everything else
    local lockfiles=()
    local otherfiles=()

    while IFS= read -r file; do
        [ -z "$file" ] && continue
        case "$file" in
            *.lock|*lock.json|*lazy-lock.json|*package-lock.json|*yarn.lock|*pnpm-lock.yaml|*Cargo.lock|*Gemfile.lock|*Brewfile.lock.json)
                lockfiles+=("$file")
                ;;
            *)
                otherfiles+=("$file")
                ;;
        esac
    done < <(git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard)

    # De-duplicate
    if [ ${#lockfiles[@]} -gt 0 ]; then
        local dedup_lock=()
        while IFS= read -r f; do dedup_lock+=("$f"); done < <(printf '%s\n' "${lockfiles[@]}" | sort -u)
        lockfiles=("${dedup_lock[@]}")
    fi
    if [ ${#otherfiles[@]} -gt 0 ]; then
        local dedup_other=()
        while IFS= read -r f; do dedup_other+=("$f"); done < <(printf '%s\n' "${otherfiles[@]}" | sort -u)
        otherfiles=("${dedup_other[@]}")
    fi

    # Commit lockfile changes
    if [ ${#lockfiles[@]} -gt 0 ]; then
        info "Committing lockfile changes..."
        if ! git add "${lockfiles[@]}" || ! git commit -m "chore: lock"; then
            collect_error "dotfiles-git" "Failed to commit lockfile changes"
        fi
    fi

    # Commit other changes
    if [ ${#otherfiles[@]} -gt 0 ]; then
        info "Committing other dotfile changes..."
        local summary="chore: post-upgrade sync"
        local details=""
        for f in "${otherfiles[@]}"; do
            details+="  - $f"$'\n'
        done
        if ! git add "${otherfiles[@]}" || ! git commit -m "$summary" -m "Updated files:"$'\n'"$details"; then
            collect_error "dotfiles-git" "Failed to commit dotfile changes"
        fi
    fi

    # Push if we have a remote
    if git remote get-url origin &>/dev/null; then
        info "Pushing to remote..."
        if ! git push 2>&1; then
            collect_error "dotfiles-git" "Failed to push to remote"
        fi
    else
        warn "No remote configured — skipping push."
    fi
}

# ── Main ─────────────────────────────────────────────────────────────

main() {
    echo -e "${BOLD}System Upgrade${RESET} — $(date '+%Y-%m-%d %H:%M')\n"

    case "$OS" in
        Darwin) upgrade_macos ;;
        Linux)  upgrade_linux ;;
        *)      err "Unsupported OS: $OS"; exit 1 ;;
    esac

    upgrade_lazyvim
    upgrade_version_managers
    commit_dotfiles

    print_error_summary

    echo ""
    if [ ${#ERRORS[@]} -eq 0 ]; then
        info "All done!"
    else
        warn "Upgrade finished with ${#ERRORS[@]} error(s)."
        exit 1
    fi
}

main "$@"
