#!/usr/bin/env bash
set -euo pipefail

# ─── Globals ────────────────────────────────────────────────────────────────────
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PLATFORM=""
INSTALL_MODE=""
STOW_PACKAGES=()
DRY_RUN=false
DRY_RUN_LOG=$(mktemp /tmp/dotfiles-dry-run.XXXXXX)
trap 'rm -f "$DRY_RUN_LOG"' EXIT

# ─── Colors & Styles (fallback if gum is not available) ─────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ─── Helpers ────────────────────────────────────────────────────────────────────
has_cmd() { command -v "$1" &>/dev/null; }

info()    { echo -e "${BLUE}▸${RESET} $*"; }
success() { echo -e "${GREEN}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET} $*"; }
error()   { echo -e "${RED}✗${RESET} $*"; }
dry() {
  echo -e "${CYAN}[dry-run]${RESET} $*"
  echo "  $*" >> "$DRY_RUN_LOG"
}

# Wraps a command: prints it in dry-run mode, executes it otherwise.
# Usage:
#   run <command> [args...]              — run directly or dry-print
#   run --spin "Title..." <cmd> [args..] — run with gum spinner or dry-print
#   run --sudo <command> [args...]       — run with sudo or dry-print "sudo ..."
run() {
  local use_spin=false spin_title="" use_sudo=false
  while true; do
    case "${1:-}" in
      --spin)  use_spin=true; shift; spin_title="$1"; shift ;;
      --sudo)  use_sudo=true; shift ;;
      *) break ;;
    esac
  done

  local prefix=""
  [[ "$use_sudo" == true ]] && prefix="sudo "

  if [[ "$DRY_RUN" == true ]]; then
    dry "${prefix}$*"
    return 0
  fi

  if [[ "$use_spin" == true ]]; then
    if [[ "$use_sudo" == true ]]; then
      gum spin --spinner dot --title "$spin_title" -- sudo "$@"
    else
      gum spin --spinner dot --title "$spin_title" -- "$@"
    fi
  elif [[ "$use_sudo" == true ]]; then
    sudo "$@"
  else
    "$@"
  fi
}

SECTION_COLORS=(212 99 214 39 48 183)
SECTION_INDEX=0

header() {
  local color="${SECTION_COLORS[$((SECTION_INDEX % ${#SECTION_COLORS[@]}))]}"
  ((SECTION_INDEX++)) || true
  echo ""
  gum style \
    --border double \
    --border-foreground "$color" \
    --foreground "$color" \
    --padding "1 3" \
    --margin "0 2" \
    --bold \
    "$@"
}

# ─── Prerequisite checks ───────────────────────────────────────────────────────
check_prerequisites() {
  local missing=()

  if ! has_cmd git; then missing+=("git"); fi
  if ! has_cmd stow; then missing+=("stow"); fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    error "Missing required tools: ${missing[*]}"
    echo ""
    if [[ "$PLATFORM" == "arch" ]]; then
      info "Install with: ${BOLD}sudo pacman -S ${missing[*]}${RESET}"
    elif [[ "$PLATFORM" == "darwin" ]]; then
      if ! has_cmd brew; then
        info "Install Homebrew first: https://brew.sh"
      fi
      info "Install with: ${BOLD}brew install ${missing[*]}${RESET}"
    fi
    exit 1
  fi
  success "Core prerequisites met (git, stow)"
}

ensure_gum() {
  if has_cmd gum; then return 0; fi

  echo ""
  warn "gum is not installed. It's needed for the interactive installer."
  echo ""
  if [[ "$PLATFORM" == "arch" ]]; then
    read -rp "Install gum via pacman? [Y/n] " ans
    if [[ "${ans:-Y}" =~ ^[Yy]$ ]]; then
      sudo pacman -S --noconfirm gum
    else
      error "Cannot continue without gum. Install it manually: pacman -S gum"
      exit 1
    fi
  elif [[ "$PLATFORM" == "darwin" ]]; then
    read -rp "Install gum via Homebrew? [Y/n] " ans
    if [[ "${ans:-Y}" =~ ^[Yy]$ ]]; then
      brew install gum
    else
      error "Cannot continue without gum. Install it manually: brew install gum"
      exit 1
    fi
  fi
}

# ─── Platform detection ─────────────────────────────────────────────────────────
detect_platform() {
  case "$(uname -s)" in
    Linux*)
      if [[ -f /etc/arch-release ]]; then
        PLATFORM="arch"
      else
        error "Unsupported Linux distribution. Only Arch Linux is supported."
        exit 1
      fi
      ;;
    Darwin*)
      PLATFORM="darwin"
      ;;
    *)
      error "Unsupported operating system: $(uname -s)"
      exit 1
      ;;
  esac
}

# ─── Package descriptions ──────────────────────────────────────────────────────
describe_package() {
  local pkg="$1"
  case "$pkg" in
    # General
    ai-agents)    echo "OpenCode AI agent configs" ;;
    atuin)        echo "Shell history sync (atuin)" ;;
    base)         echo "Shell core: zshrc, aliases, exports, git, mise, p10k" ;;
    btop)         echo "System monitor (btop)" ;;
    claude)       echo "Claude Code settings, skills, commands" ;;
    fastfetch)    echo "System info fetcher (fastfetch)" ;;
    kitty)        echo "Kitty terminal config" ;;
    neofetch)     echo "System info (neofetch, legacy)" ;;
    nvim)         echo "Neovim config (LazyVim)" ;;
    rio)          echo "Rio terminal config" ;;
    satty)        echo "Screenshot annotation tool" ;;
    yazi)         echo "Terminal file manager (yazi)" ;;
    zellij)       echo "Terminal multiplexer (zellij)" ;;
    # Arch
    bin)          echo "Custom scripts (fix-desktop-icons, run-exe)" ;;
    clipcat)      echo "Clipboard manager daemon" ;;
    elephant)     echo "App launcher (elephant)" ;;
    gtk)          echo "GTK 2/3 theme settings" ;;
    hyprland)     echo "Hyprland window manager config" ;;
    keyd)         echo "Key remapping daemon [sudo]" ;;
    keyd-app-remapper) echo "Per-app key remapping" ;;
    mako)         echo "Notification daemon (mako)" ;;
    nwg-bar)      echo "Logout/power bar (nwg-bar)" ;;
    nwg-drawer)   echo "Application drawer (nwg-drawer)" ;;
    pacman)       echo "Pacman config and hooks [sudo]" ;;
    pipewire)     echo "PipeWire/WirePlumber audio config" ;;
    pywal)        echo "Color scheme templates (pywal)" ;;
    sddm)         echo "Display manager config [sudo]" ;;
    swaync)       echo "Notification center (swaync)" ;;
    themes)       echo "Icon and cursor themes" ;;
    walker)       echo "Application launcher (walker)" ;;
    waybar)       echo "Status bar (Waybar)" ;;
    waypaper)     echo "Wallpaper manager" ;;
    wofi)         echo "Application launcher (wofi)" ;;
    x)            echo "X11 settings (XCompose, Xresources)" ;;
    # Darwin
    dotfiles)     echo "Brewfile and Karabiner config" ;;
    karabiner)    echo "Karabiner-Elements key remapping" ;;
    *)            echo "" ;;
  esac
}

# ─── List stow packages ────────────────────────────────────────────────────────
list_packages() {
  local dir="$1"
  local packages=()
  for d in "$dir"/*/; do
    local name
    name="$(basename "$d")"
    [[ "$name" == "non-stowable" ]] && continue
    packages+=("$name")
  done
  printf '%s\n' "${packages[@]}" | sort
}

# ─── Build display labels for gum ──────────────────────────────────────────────
build_package_labels() {
  local -n pkgs=$1
  local labels=()
  for pkg in "${pkgs[@]}"; do
    local desc
    desc="$(describe_package "$pkg")"
    if [[ -n "$desc" ]]; then
      labels+=("$(printf '%-22s %s' "$pkg" "$desc")")
    else
      labels+=("$pkg")
    fi
  done
  printf '%s\n' "${labels[@]}"
}

# ─── Read stowTargets.json ─────────────────────────────────────────────────────
# Returns JSON lines: one per stow operation for the given package.
# Format per line: {"subdir":"etc","target":"/","sudo":true}
# If no custom entries, returns: {"subdir":".","target":"$HOME","sudo":false}
get_stow_operations() {
  local platform_dir="$1"
  local pkg="$2"
  local targets_file="$platform_dir/stowTargets.json"

  if [[ ! -f "$targets_file" ]] || ! has_cmd python3; then
    echo "{\"subdir\":\".\",\"target\":\"$HOME\",\"sudo\":false}"
    return
  fi

  python3 -c "
import json, sys, os
with open('$targets_file') as f:
    data = json.load(f)
custom = data.get('custom', {})
default_target = data.get('default', '\$HOME').replace('\$HOME', os.environ['HOME'])
found = []
for key, val in custom.items():
    parts = key.split('/', 1)
    if parts[0] == '${pkg}':
        subdir = parts[1] if len(parts) > 1 else '.'
        target = val.get('target', default_target).replace('\$HOME', os.environ['HOME'])
        sudo = 'true' if val.get('sudo', False) else 'false'
        found.append('{\"subdir\":\"' + subdir + '\",\"target\":\"' + target + '\",\"sudo\":' + sudo + '}')
if not found:
    found.append('{\"subdir\":\".\",\"target\":\"' + default_target + '\",\"sudo\":false}')
print('\n'.join(found))
" 2>/dev/null
}

needs_sudo() {
  local platform_dir="$1"
  local pkg="$2"
  local ops
  ops=$(get_stow_operations "$platform_dir" "$pkg")
  echo "$ops" | grep -q '"sudo":true'
}

# ─── Stow a single package ─────────────────────────────────────────────────────
# Handles subdir-based stow targets from stowTargets.json.
# e.g., keyd/etc with target "/" becomes: stow --dir=<path>/keyd --target=/ etc
stow_package() {
  local source_dir="$1"
  local pkg="$2"
  local platform_dir="$3"

  local ops
  ops=$(get_stow_operations "$platform_dir" "$pkg")
  local all_output=""
  local any_failed=false

  while IFS= read -r op; do
    local subdir target use_sudo
    subdir=$(echo "$op" | python3 -c "import json,sys; print(json.load(sys.stdin)['subdir'])")
    target=$(echo "$op" | python3 -c "import json,sys; print(json.load(sys.stdin)['target'])")
    use_sudo=$(echo "$op" | python3 -c "import json,sys; print(str(json.load(sys.stdin)['sudo']).lower())")

    local stow_dir stow_pkg
    if [[ "$subdir" == "." ]]; then
      stow_dir="$source_dir"
      stow_pkg="$pkg"
    else
      stow_dir="$source_dir/$pkg"
      stow_pkg="$subdir"
    fi

    local stow_cmd=(stow --restow --verbose --dir="$stow_dir" --target="$target" "$stow_pkg")

    if [[ "$DRY_RUN" == true ]]; then
      local prefix=""
      [[ "$use_sudo" == "true" ]] && prefix="sudo "
      dry "${prefix}${stow_cmd[*]}"
    elif [[ "$use_sudo" == "true" ]]; then
      local output
      output=$(sudo "${stow_cmd[@]}" 2>&1) || any_failed=true
      all_output+="$output"$'\n'
    else
      local output
      output=$("${stow_cmd[@]}" 2>&1) || any_failed=true
      all_output+="$output"$'\n'
    fi
  done <<< "$ops"

  if [[ "$DRY_RUN" == true ]]; then
    return 0
  elif [[ "$any_failed" == "true" ]]; then
    echo "$all_output"
    return 1
  else
    echo "$all_output"
    return 0
  fi
}

# ─── Stow packages with progress ───────────────────────────────────────────────
run_stow() {
  local source_dir="$1"
  shift
  local packages=("$@")
  # source_dir IS the platform dir (e.g., specific/arch/) or general/
  local platform_dir="$source_dir"

  local succeeded=0
  local failed=0
  local skipped=0
  local errors=()

  for pkg in "${packages[@]}"; do
    local pkg_path="$source_dir/$pkg"

    if [[ ! -d "$pkg_path" ]]; then
      warn "Package directory not found: $pkg"
      ((skipped++)) || true
      continue
    fi

    local label="$pkg"
    if needs_sudo "$platform_dir" "$pkg"; then
      label="$pkg (sudo)"
    fi

    if [[ "$DRY_RUN" == true ]]; then
      stow_package "$source_dir" "$pkg" "$platform_dir"
      ((succeeded++)) || true
    else
      local output
      if output=$(stow_package "$source_dir" "$pkg" "$platform_dir" 2>&1); then
        success "$label"
        ((succeeded++)) || true
      else
        error "$label"
        errors+=("$pkg: $output")
        ((failed++)) || true
      fi
    fi
  done

  echo ""
  gum style --foreground 99 "Results: ${succeeded} ok, ${failed} failed, ${skipped} skipped"

  if [[ ${#errors[@]} -gt 0 ]]; then
    echo ""
    warn "Errors:"
    for err in "${errors[@]}"; do
      echo -e "  ${DIM}$err${RESET}"
    done
  fi
}

# ─── Install system packages (fresh install mode) ──────────────────────────────
install_system_packages() {
  header "System Package Installation"

  if [[ "$PLATFORM" == "arch" ]]; then
    install_arch_packages
  elif [[ "$PLATFORM" == "darwin" ]]; then
    install_darwin_packages
  fi
}

install_arch_packages() {
  local dump_file="$DOTFILES_DIR/specific/arch/non-stowable/pacman/pacman.dump"

  if [[ ! -f "$dump_file" ]]; then
    warn "No pacman.dump found, skipping package installation"
    return
  fi

  local total
  total=$(wc -l < "$dump_file")
  info "Found ${BOLD}$total${RESET} packages in pacman.dump"
  echo ""

  local choice
  choice=$(gum choose \
    "Install all packages" \
    "Select packages to install" \
    "Skip package installation")

  case "$choice" in
    "Install all packages")
      if ! has_cmd yay; then
        warn "yay not found. Some AUR packages may fail with pacman alone."
        if gum confirm "Install yay first?"; then
          install_yay
        fi
      fi

      local pkg_manager="pacman"
      if has_cmd yay; then pkg_manager="yay"; fi

      info "Installing packages with $pkg_manager..."
      run --spin "Installing packages..." \
        bash -c "$pkg_manager -S --needed --noconfirm - < '$dump_file' 2>&1 || true"
      success "Package installation complete"
      ;;

    "Select packages to install")
      local selected
      selected=$(cat "$dump_file" | gum filter --no-limit --height 25 \
        --header "Space to select, Enter to confirm" \
        --placeholder "Type to filter packages...")

      if [[ -n "$selected" ]]; then
        local pkg_manager="pacman"
        if has_cmd yay; then pkg_manager="yay"; fi

        echo "$selected" | while read -r pkg; do
          run --spin "Installing $pkg..." \
            bash -c "$pkg_manager -S --needed --noconfirm '$pkg' 2>&1 || true"
          success "$pkg"
        done
      fi
      ;;

    "Skip package installation")
      info "Skipping package installation"
      ;;
  esac
}

install_yay() {
  info "Installing yay from AUR..."
  local tmpdir
  tmpdir=$(mktemp -d)
  run --spin "Cloning yay..." git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  run bash -c "cd '$tmpdir/yay' && makepkg -si --noconfirm"
  rm -rf "$tmpdir"
  success "yay installed"
}

install_darwin_packages() {
  if ! has_cmd brew; then
    warn "Homebrew is not installed."
    if gum confirm "Install Homebrew?"; then
      run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      success "Homebrew installed"
    else
      warn "Skipping package installation (no Homebrew)"
      return
    fi
  fi

  local brewfile="$DOTFILES_DIR/specific/darwin/dotfiles/Brewfile"
  if [[ ! -f "$brewfile" ]]; then
    warn "No Brewfile found, skipping"
    return
  fi

  info "Found Brewfile at ${DIM}$brewfile${RESET}"
  echo ""

  local choice
  choice=$(gum choose \
    "Install all from Brewfile" \
    "Select packages to install" \
    "Skip package installation")

  case "$choice" in
    "Install all from Brewfile")
      info "Running brew bundle..."
      run --spin "Installing from Brewfile..." brew bundle --file="$brewfile"
      success "Brew bundle complete"
      ;;

    "Select packages to install")
      local formulas
      formulas=$(grep -E '^(brew|cask|tap) ' "$brewfile" | gum filter --no-limit --height 25 \
        --header "Space to select, Enter to confirm" \
        --placeholder "Type to filter packages...")

      if [[ -n "$formulas" ]]; then
        echo "$formulas" | while read -r line; do
          local type name
          type=$(echo "$line" | awk '{print $1}')
          name=$(echo "$line" | awk '{print $2}' | tr -d '"')
          case "$type" in
            tap)  run --spin "Tapping $name..." brew tap "$name" ;;
            brew) run --spin "Installing $name..." brew install "$name" ;;
            cask) run --spin "Installing $name..." brew install --cask "$name" ;;
          esac
          success "$name"
        done
      fi
      ;;

    "Skip package installation")
      info "Skipping package installation"
      ;;
  esac
}

# ─── Darwin one-time commands ───────────────────────────────────────────────────
run_darwin_one_time() {
  local otc_dir="$DOTFILES_DIR/specific/darwin/non-stowable/one-time-commands"
  if [[ ! -d "$otc_dir" ]]; then return; fi
  if [[ -f "$HOME/.one-time-commands-run" ]]; then
    info "One-time commands already executed (marker file exists)"
    if ! gum confirm "Run them again?"; then
      return
    fi
  fi

  header "macOS One-Time Commands"
  info "These tweak macOS defaults (screenshots, dock, hidden apps, etc.)"
  echo ""

  if gum confirm "Run one-time macOS commands?"; then
    run bash "$otc_dir/run-one-time-commands.sh"
    success "One-time commands executed"
  else
    info "Skipped one-time commands"
  fi
}

# ─── Systemd units (Arch) ──────────────────────────────────────────────────────
enable_systemd_units() {
  local unit_dir="$DOTFILES_DIR/specific/arch/base/.config/systemd/user"
  if [[ ! -d "$unit_dir" ]]; then return; fi

  local units=()
  while IFS= read -r -d '' f; do
    local name
    name="$(basename "$f")"
    units+=("$name")
  done < <(find "$unit_dir" -maxdepth 1 \( -name '*.service' -o -name '*.timer' \) -print0 2>/dev/null)

  if [[ ${#units[@]} -eq 0 ]]; then return; fi

  header "Systemd User Units"
  info "Found ${#units[@]} user units that can be enabled"
  echo ""

  local choice
  choice=$(gum choose \
    "Enable all units" \
    "Select units to enable" \
    "Skip")

  case "$choice" in
    "Enable all units")
      for unit in "${units[@]}"; do
        if run systemctl --user enable --now "$unit" 2>/dev/null; then
          success "$unit"
        else
          warn "$unit (may need dependencies)"
        fi
      done
      ;;
    "Select units to enable")
      local selected
      selected=$(printf '%s\n' "${units[@]}" | gum filter --no-limit --height 20 \
        --header "Space to select, Enter to confirm")
      if [[ -n "$selected" ]]; then
        echo "$selected" | while read -r unit; do
          if run systemctl --user enable --now "$unit" 2>/dev/null; then
            success "$unit"
          else
            warn "$unit (may need dependencies)"
          fi
        done
      fi
      ;;
    "Skip")
      info "Skipped systemd units"
      ;;
  esac
}

# ─── Main flow ──────────────────────────────────────────────────────────────────
main() {
  for arg in "$@"; do
    case "$arg" in
      --dry-run|-n) DRY_RUN=true ;;
      --help|-h)
        echo "Usage: ./install.sh [--dry-run|-n] [--help|-h]"
        echo "  --dry-run, -n   Show what would be done without making changes"
        exit 0
        ;;
    esac
  done

  clear

  # Banner
  if has_cmd gum; then
    gum style \
      --border thick \
      --border-foreground 212 \
      --padding "1 4" \
      --margin "1 2" \
      --bold \
      --foreground 212 \
      " ╺┳┓  ┏━┓ ╺┳╸ ┏━╸ ╻  ╻  ┏━╸ ┏━┓" \
      "  ┃┃  ┃ ┃  ┃  ┣╸  ┃  ┃  ┣╸  ┗━┓" \
      " ╺┻┛  ┗━┛  ╹  ╹   ╹  ┗━╸┗━╸ ┗━┛" \
      "" \
      "  khaosdoctor/dotfiles installer"
  else
    echo "=== dotfiles installer ==="
  fi

  if [[ "$DRY_RUN" == true ]]; then
    gum style --foreground 14 --bold --margin "0 2" \
      "  DRY RUN MODE — no changes will be made"
  fi

  # ── Step 1: Detect platform ──
  detect_platform
  success "Detected platform: ${BOLD}$PLATFORM${RESET}"

  # ── Step 2: Ensure gum is available ──
  ensure_gum

  # ── Step 3: Check prerequisites ──
  check_prerequisites

  # ── Step 4: Install mode ──
  header "Installation Mode"
  INSTALL_MODE=$(gum choose --header "What kind of setup is this?" \
    "fresh    ── New system, install packages + stow configs" \
    "existing ── System already set up, just stow/update configs")
  INSTALL_MODE="${INSTALL_MODE%% *}"

  # ── Step 5: Install system packages (fresh only) ──
  if [[ "$INSTALL_MODE" == "fresh" ]]; then
    install_system_packages
  fi

  # ── Step 6: Select and stow general packages ──
  header "General Packages" "(cross-platform configs)"

  local general_dir="$DOTFILES_DIR/general"
  mapfile -t general_pkgs < <(list_packages "$general_dir")

  info "Found ${#general_pkgs[@]} general packages"
  echo ""

  local gen_choice
  gen_choice=$(gum choose \
    "Stow all general packages" \
    "Select packages to stow" \
    "Skip general packages")

  case "$gen_choice" in
    "Stow all general packages")
      run_stow "$general_dir" "${general_pkgs[@]}"
      ;;
    "Select packages to stow")
      local labels selected_labels
      labels=$(build_package_labels general_pkgs)
      selected_labels=$(echo "$labels" | gum filter --no-limit --height 20 \
        --header "Space to select, Enter to confirm" \
        --placeholder "Type to filter...")

      if [[ -n "$selected_labels" ]]; then
        local selected_pkgs=()
        while IFS= read -r label; do
          selected_pkgs+=("$(echo "$label" | awk '{print $1}')")
        done <<< "$selected_labels"
        run_stow "$general_dir" "${selected_pkgs[@]}"
      fi
      ;;
    "Skip general packages")
      info "Skipped general packages"
      ;;
  esac

  # ── Step 7: Select and stow platform-specific packages ──
  local specific_dir="$DOTFILES_DIR/specific/$PLATFORM"

  if [[ -d "$specific_dir" ]]; then
    header "Platform Packages" "($PLATFORM-specific configs)"

    mapfile -t platform_pkgs < <(list_packages "$specific_dir")

    info "Found ${#platform_pkgs[@]} $PLATFORM-specific packages"

    # Warn about sudo packages
    local sudo_pkgs=()
    for pkg in "${platform_pkgs[@]}"; do
      if needs_sudo "$specific_dir" "$pkg"; then
        sudo_pkgs+=("$pkg")
      fi
    done
    if [[ ${#sudo_pkgs[@]} -gt 0 ]]; then
      warn "These packages require sudo: ${BOLD}${sudo_pkgs[*]}${RESET}"
    fi
    echo ""

    local plat_choice
    plat_choice=$(gum choose \
      "Stow all $PLATFORM packages" \
      "Select packages to stow" \
      "Skip $PLATFORM packages")

    case "$plat_choice" in
      "Stow all $PLATFORM packages")
        run_stow "$specific_dir" "${platform_pkgs[@]}"
        ;;
      "Select packages to stow")
        local labels selected_labels
        labels=$(build_package_labels platform_pkgs)
        selected_labels=$(echo "$labels" | gum filter --no-limit --height 20 \
          --header "Space to select, Enter to confirm" \
          --placeholder "Type to filter...")

        if [[ -n "$selected_labels" ]]; then
          local selected_pkgs=()
          while IFS= read -r label; do
            selected_pkgs+=("$(echo "$label" | awk '{print $1}')")
          done <<< "$selected_labels"
          run_stow "$specific_dir" "${selected_pkgs[@]}"
        fi
        ;;
      "Skip $PLATFORM packages")
        info "Skipped $PLATFORM packages"
        ;;
    esac
  fi

  # ── Step 8: Platform-specific post-install ──
  if [[ "$PLATFORM" == "darwin" ]]; then
    run_darwin_one_time
  elif [[ "$PLATFORM" == "arch" ]]; then
    enable_systemd_units
  fi

  # ── Done ──
  echo ""
  if [[ "$DRY_RUN" == true ]]; then
    local log_lines
    log_lines=$(wc -l < "$DRY_RUN_LOG")
    echo ""
    gum style \
      --border rounded \
      --border-foreground 14 \
      --padding "1 3" \
      --margin "0 2" \
      --foreground 14 \
      --bold \
      "Dry run complete! ($log_lines commands would be executed)" \
      "" \
      "No changes were made. Run without --dry-run to apply."
    if [[ "$log_lines" -gt 0 ]]; then
      echo ""
      gum style --foreground 14 --bold --margin "0 2" "Commands that would run:"
      cat "$DRY_RUN_LOG"
    fi
  else
    gum style \
      --border rounded \
      --border-foreground 46 \
      --padding "1 3" \
      --margin "0 2" \
      --foreground 46 \
      --bold \
      "All done!" \
      "" \
      "You may want to:" \
      "  - Restart your shell (exec zsh)" \
      "  - Log out and back in for systemd/DE changes" \
      "  - Check specific/arch/README.md for theme setup notes"
  fi
}

main "$@"
