package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"sort"
	"strings"

	"github.com/charmbracelet/huh"
	"github.com/charmbracelet/huh/spinner"
	"github.com/charmbracelet/lipgloss"
)

// ─── Palette ───────────────────────────────────────────────────────────────────

var sectionColors = []lipgloss.Color{"212", "99", "214", "39", "48", "183"}
var sectionIndex int

var (
	colorGreen  = lipgloss.NewStyle().Foreground(lipgloss.Color("46"))
	colorYellow = lipgloss.NewStyle().Foreground(lipgloss.Color("214"))
	colorRed    = lipgloss.NewStyle().Foreground(lipgloss.Color("196"))
	colorBlue   = lipgloss.NewStyle().Foreground(lipgloss.Color("33"))
	colorCyan   = lipgloss.NewStyle().Foreground(lipgloss.Color("14"))
	colorDim    = lipgloss.NewStyle().Faint(true)
)

func info(msg string)    { fmt.Println(colorBlue.Render("▸") + " " + msg) }
func success(msg string) { fmt.Println(colorGreen.Render("✓") + " " + msg) }
func warn(msg string)    { fmt.Println(colorYellow.Render("⚠") + " " + msg) }
func errMsg(msg string)  { fmt.Println(colorRed.Render("✗") + " " + msg) }

func header(lines ...string) {
	color := sectionColors[sectionIndex%len(sectionColors)]
	sectionIndex++

	style := lipgloss.NewStyle().
		Border(lipgloss.DoubleBorder()).
		BorderForeground(color).
		Foreground(color).
		Padding(1, 3).
		MarginLeft(2).
		Bold(true)

	fmt.Println()
	fmt.Println(style.Render(strings.Join(lines, "\n")))
}

// quit prints a goodbye message and exits cleanly.
func quit() {
	fmt.Println()
	info("Cancelled. No changes were made.")
	os.Exit(0)
}

// checkAbort exits gracefully if the user pressed Esc/Ctrl+C on a huh prompt.
func checkAbort(err error) {
	if err != nil && errors.Is(err, huh.ErrUserAborted) {
		quit()
	}
}

// ─── Types ─────────────────────────────────────────────────────────────────────

type StowTarget struct {
	Target string `json:"target"`
	Sudo   bool   `json:"sudo"`
}

type StowTargets struct {
	Default string                `json:"default"`
	Custom  map[string]StowTarget `json:"custom"`
}

type StowOp struct {
	Subdir string
	Target string
	Sudo   bool
}

// ─── Descriptions ──────────────────────────────────────────────────────────────

var packageDescriptions = map[string]string{
	// General
	"ai-agents":  "OpenCode AI agent configs",
	"atuin":      "Shell history sync (atuin)",
	"base":       "Shell core: zshrc, aliases, exports, git, mise, p10k",
	"btop":       "System monitor (btop)",
	"claude":     "Claude Code settings, skills, commands",
	"fastfetch":  "System info fetcher (fastfetch)",
	"kitty":      "Kitty terminal config",
	"neofetch":   "System info (neofetch, legacy)",
	"nvim":       "Neovim config (LazyVim)",
	"rio":        "Rio terminal config",
	"satty":      "Screenshot annotation tool",
	"yazi":       "Terminal file manager (yazi)",
	"zellij":     "Terminal multiplexer (zellij)",
	// Arch
	"bin":               "Custom scripts (fix-desktop-icons, run-exe)",
	"clipcat":           "Clipboard manager daemon",
	"elephant":          "App launcher (elephant)",
	"gtk":               "GTK 2/3 theme settings",
	"hyprland":          "Hyprland window manager config",
	"keyd":              "Key remapping daemon [sudo]",
	"keyd-app-remapper": "Per-app key remapping",
	"mako":              "Notification daemon (mako)",
	"nwg-bar":           "Logout/power bar (nwg-bar)",
	"nwg-drawer":        "Application drawer (nwg-drawer)",
	"pacman":            "Pacman config and hooks [sudo]",
	"pipewire":          "PipeWire/WirePlumber audio config",
	"pywal":             "Color scheme templates (pywal)",
	"sddm":              "Display manager config [sudo]",
	"swaync":            "Notification center (swaync)",
	"themes":            "Icon and cursor themes",
	"walker":            "Application launcher (walker)",
	"waybar":            "Status bar (Waybar)",
	"waypaper":          "Wallpaper manager",
	"wofi":              "Application launcher (wofi)",
	"x":                 "X11 settings (XCompose, Xresources)",
	// Darwin
	"dotfiles":  "Brewfile and Karabiner config",
	"karabiner": "Karabiner-Elements key remapping",
}

// ─── Config ────────────────────────────────────────────────────────────────────

type Config struct {
	DotfilesDir string
	Platform    string // "arch" or "darwin"
	DryRun      bool
	DryRunLog   []string
}

// ─── Helpers ───────────────────────────────────────────────────────────────────

func hasCmd(name string) bool {
	_, err := exec.LookPath(name)
	return err == nil
}

func (c *Config) dry(cmd string) {
	fmt.Println(colorCyan.Render("[dry-run]") + " " + cmd)
	c.DryRunLog = append(c.DryRunLog, cmd)
}

func (c *Config) runCmd(args ...string) error {
	cmdStr := strings.Join(args, " ")
	if c.DryRun {
		c.dry(cmdStr)
		return nil
	}
	cmd := exec.Command(args[0], args[1:]...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}

func (c *Config) runCmdSudo(args ...string) error {
	if c.DryRun {
		c.dry("sudo " + strings.Join(args, " "))
		return nil
	}
	full := append([]string{"sudo"}, args...)
	cmd := exec.Command(full[0], full[1:]...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}

func (c *Config) runSpin(title string, fn func() error) error {
	if c.DryRun {
		return nil
	}
	return spinner.New().Title(title).Action(func() {
		fn() //nolint:errcheck
	}).Run()
}

// ─── Platform detection ────────────────────────────────────────────────────────

func detectPlatform() (string, error) {
	switch runtime.GOOS {
	case "linux":
		if _, err := os.Stat("/etc/arch-release"); err == nil {
			return "arch", nil
		}
		return "", fmt.Errorf("unsupported Linux distribution (only Arch is supported)")
	case "darwin":
		return "darwin", nil
	default:
		return "", fmt.Errorf("unsupported operating system: %s", runtime.GOOS)
	}
}

// ─── Prerequisites ─────────────────────────────────────────────────────────────

func checkPrerequisites(platform string) error {
	var missing []string
	for _, tool := range []string{"git", "stow"} {
		if !hasCmd(tool) {
			missing = append(missing, tool)
		}
	}
	if len(missing) == 0 {
		success("Core prerequisites met (git, stow)")
		return nil
	}

	errMsg("Missing required tools: " + strings.Join(missing, ", "))
	if platform == "arch" {
		info("Install with: sudo pacman -S " + strings.Join(missing, " "))
	} else {
		info("Install with: brew install " + strings.Join(missing, " "))
	}
	return fmt.Errorf("missing prerequisites")
}

// ─── Package listing ───────────────────────────────────────────────────────────

func listPackages(dir string) ([]string, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}
	var pkgs []string
	for _, e := range entries {
		if e.IsDir() && e.Name() != "non-stowable" && !strings.HasPrefix(e.Name(), ".") {
			pkgs = append(pkgs, e.Name())
		}
	}
	sort.Strings(pkgs)
	return pkgs, nil
}

func formatPackageOption(pkg string) string {
	if desc, ok := packageDescriptions[pkg]; ok {
		return fmt.Sprintf("%-22s %s", pkg, desc)
	}
	return pkg
}

// ─── Stow targets ─────────────────────────────────────────────────────────────

func loadStowTargets(platformDir string) *StowTargets {
	path := filepath.Join(platformDir, "stowTargets.json")
	data, err := os.ReadFile(path)
	if err != nil {
		return nil
	}
	var targets StowTargets
	if err := json.Unmarshal(data, &targets); err != nil {
		return nil
	}
	return &targets
}

func getStowOps(targets *StowTargets, pkg string) []StowOp {
	home := os.Getenv("HOME")

	if targets == nil {
		return []StowOp{{Subdir: ".", Target: home, Sudo: false}}
	}

	defaultTarget := targets.Default
	if defaultTarget == "$HOME" || defaultTarget == "" {
		defaultTarget = home
	}

	var ops []StowOp
	for key, val := range targets.Custom {
		parts := strings.SplitN(key, "/", 2)
		if parts[0] != pkg {
			continue
		}
		subdir := "."
		if len(parts) > 1 {
			subdir = parts[1]
		}
		target := val.Target
		if target == "$HOME" || target == "" {
			target = defaultTarget
		}
		ops = append(ops, StowOp{Subdir: subdir, Target: target, Sudo: val.Sudo})
	}

	if len(ops) == 0 {
		ops = append(ops, StowOp{Subdir: ".", Target: defaultTarget, Sudo: false})
	}
	return ops
}

func needsSudo(targets *StowTargets, pkg string) bool {
	for _, op := range getStowOps(targets, pkg) {
		if op.Sudo {
			return true
		}
	}
	return false
}

// ─── Stow execution ───────────────────────────────────────────────────────────

func (c *Config) stowPackage(sourceDir, pkg string, targets *StowTargets) error {
	ops := getStowOps(targets, pkg)
	var errs []string

	for _, op := range ops {
		stowDir := sourceDir
		stowPkg := pkg
		if op.Subdir != "." {
			stowDir = filepath.Join(sourceDir, pkg)
			stowPkg = op.Subdir
		}

		args := []string{"stow", "--restow", "--verbose",
			"--dir=" + stowDir, "--target=" + op.Target, stowPkg}

		if c.DryRun {
			prefix := ""
			if op.Sudo {
				prefix = "sudo "
			}
			c.dry(prefix + strings.Join(args, " "))
			continue
		}

		var cmd *exec.Cmd
		if op.Sudo {
			cmd = exec.Command("sudo", args...)
		} else {
			cmd = exec.Command(args[0], args[1:]...)
		}
		out, err := cmd.CombinedOutput()
		if err != nil {
			errs = append(errs, fmt.Sprintf("%s: %s", err, strings.TrimSpace(string(out))))
		}
	}

	if len(errs) > 0 {
		return fmt.Errorf("%s", strings.Join(errs, "; "))
	}
	return nil
}

type stowResult struct {
	succeeded int
	failed    int
	skipped   int
	errors    []string
}

func (c *Config) runStow(sourceDir string, packages []string) stowResult {
	targets := loadStowTargets(sourceDir)
	res := stowResult{}

	for _, pkg := range packages {
		pkgPath := filepath.Join(sourceDir, pkg)
		if _, err := os.Stat(pkgPath); os.IsNotExist(err) {
			warn("Package directory not found: " + pkg)
			res.skipped++
			continue
		}

		label := pkg
		if needsSudo(targets, pkg) {
			label = pkg + " (sudo)"
		}

		err := c.stowPackage(sourceDir, pkg, targets)
		if err != nil {
			errMsg(label)
			res.errors = append(res.errors, pkg+": "+err.Error())
			res.failed++
		} else {
			if !c.DryRun {
				success(label)
			}
			res.succeeded++
		}
	}

	fmt.Println()
	resultStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("99"))
	fmt.Println(resultStyle.Render(
		fmt.Sprintf("Results: %d ok, %d failed, %d skipped",
			res.succeeded, res.failed, res.skipped)))

	if len(res.errors) > 0 {
		fmt.Println()
		warn("Errors:")
		for _, e := range res.errors {
			fmt.Println("  " + colorDim.Render(e))
		}
	}
	return res
}

// ─── Package installation ──────────────────────────────────────────────────────

func (c *Config) installArchPackages() {
	dumpFile := filepath.Join(c.DotfilesDir, "specific/arch/non-stowable/pacman/pacman.dump")
	data, err := os.ReadFile(dumpFile)
	if err != nil {
		warn("No pacman.dump found, skipping package installation")
		return
	}

	allPkgs := strings.Split(strings.TrimSpace(string(data)), "\n")
	info(fmt.Sprintf("Found %d packages in pacman.dump", len(allPkgs)))

	var choice string
	checkAbort(huh.NewSelect[string]().
		Options(
			huh.NewOption("Install all packages", "all"),
			huh.NewOption("Select packages to install", "select"),
			huh.NewOption("Skip package installation", "skip"),
			huh.NewOption("Quit", "quit"),
		).
		Value(&choice).
		Run())
	if choice == "quit" {
		quit()
	}

	pkgManager := "pacman"
	if hasCmd("yay") {
		pkgManager = "yay"
	}

	switch choice {
	case "all":
		if !hasCmd("yay") {
			warn("yay not found. Some AUR packages may fail with pacman alone.")
			var installYay bool
			checkAbort(huh.NewConfirm().Title("Install yay first?").Value(&installYay).Run())
			if installYay {
				c.doInstallYay()
				pkgManager = "yay"
			}
		}
		info("Installing packages with " + pkgManager + "...")
		c.runSpin("Installing packages...", func() error { //nolint:errcheck
			return c.runCmd("bash", "-c",
				pkgManager+" -S --needed --noconfirm - < '"+dumpFile+"' 2>&1 || true")
		})
		success("Package installation complete")

	case "select":
		options := make([]huh.Option[string], 0, len(allPkgs))
		for _, pkg := range allPkgs {
			options = append(options, huh.NewOption(pkg, pkg))
		}
		var selected []string
		checkAbort(huh.NewMultiSelect[string]().
			Title("Select packages to install").
			Options(options...).
			Value(&selected).
			Height(25).
			Run())

		for _, pkg := range selected {
			c.runSpin("Installing "+pkg+"...", func() error {
				return c.runCmd("bash", "-c",
					pkgManager+" -S --needed --noconfirm '"+pkg+"' 2>&1 || true")
			})
			success(pkg)
		}

	case "skip":
		info("Skipping package installation")
	}
}

func (c *Config) doInstallYay() {
	info("Installing yay from AUR...")
	tmpDir, _ := os.MkdirTemp("", "yay-install")
	defer os.RemoveAll(tmpDir)

	c.runSpin("Cloning yay...", func() error { //nolint:errcheck
		return c.runCmd("git", "clone", "https://aur.archlinux.org/yay.git", filepath.Join(tmpDir, "yay"))
	})
	c.runCmd("bash", "-c", "cd '"+filepath.Join(tmpDir, "yay")+"' && makepkg -si --noconfirm") //nolint:errcheck
	success("yay installed")
}

func (c *Config) installDarwinPackages() {
	if !hasCmd("brew") {
		warn("Homebrew is not installed.")
		var install bool
		checkAbort(huh.NewConfirm().Title("Install Homebrew?").Value(&install).Run())
		if install {
			c.runCmd("/bin/bash", "-c", "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)") //nolint:errcheck
			success("Homebrew installed")
		} else {
			warn("Skipping package installation (no Homebrew)")
			return
		}
	}

	brewfile := filepath.Join(c.DotfilesDir, "specific/darwin/dotfiles/Brewfile")
	data, err := os.ReadFile(brewfile)
	if err != nil {
		warn("No Brewfile found, skipping")
		return
	}

	info("Found Brewfile")

	var choice string
	checkAbort(huh.NewSelect[string]().
		Options(
			huh.NewOption("Install all from Brewfile", "all"),
			huh.NewOption("Select packages to install", "select"),
			huh.NewOption("Skip package installation", "skip"),
			huh.NewOption("Quit", "quit"),
		).
		Value(&choice).
		Run())
	if choice == "quit" {
		quit()
	}

	switch choice {
	case "all":
		info("Running brew bundle...")
		c.runSpin("Installing from Brewfile...", func() error {
			return c.runCmd("brew", "bundle", "--file="+brewfile)
		})
		success("Brew bundle complete")

	case "select":
		var formulas []string
		for _, line := range strings.Split(string(data), "\n") {
			line = strings.TrimSpace(line)
			if strings.HasPrefix(line, "brew ") || strings.HasPrefix(line, "cask ") || strings.HasPrefix(line, "tap ") {
				formulas = append(formulas, line)
			}
		}

		options := make([]huh.Option[string], 0, len(formulas))
		for _, f := range formulas {
			options = append(options, huh.NewOption(f, f))
		}

		var selected []string
		checkAbort(huh.NewMultiSelect[string]().
			Title("Select packages to install").
			Options(options...).
			Value(&selected).
			Height(25).
			Run())

		for _, line := range selected {
			parts := strings.Fields(line)
			if len(parts) < 2 {
				continue
			}
			typ := parts[0]
			name := strings.Trim(parts[1], "\"")

			switch typ {
			case "tap":
				c.runSpin("Tapping "+name+"...", func() error { return c.runCmd("brew", "tap", name) }) //nolint:errcheck
			case "brew":
				c.runSpin("Installing "+name+"...", func() error { return c.runCmd("brew", "install", name) }) //nolint:errcheck
			case "cask":
				c.runSpin("Installing "+name+"...", func() error { return c.runCmd("brew", "install", "--cask", name) }) //nolint:errcheck
			}
			success(name)
		}

	case "skip":
		info("Skipping package installation")
	}
}

// ─── Darwin one-time commands ──────────────────────────────────────────────────

func (c *Config) runDarwinOneTime() {
	otcDir := filepath.Join(c.DotfilesDir, "specific/darwin/non-stowable/one-time-commands")
	if _, err := os.Stat(otcDir); os.IsNotExist(err) {
		return
	}

	marker := filepath.Join(os.Getenv("HOME"), ".one-time-commands-run")
	if _, err := os.Stat(marker); err == nil {
		info("One-time commands already executed (marker file exists)")
		var rerun bool
		checkAbort(huh.NewConfirm().Title("Run them again?").Value(&rerun).Run())
		if !rerun {
			return
		}
	}

	header("macOS One-Time Commands")
	info("These tweak macOS defaults (screenshots, dock, hidden apps, etc.)")

	var runOTC bool
	checkAbort(huh.NewConfirm().Title("Run one-time macOS commands?").Value(&runOTC).Run())
	if runOTC {
		c.runCmd("bash", filepath.Join(otcDir, "run-one-time-commands.sh")) //nolint:errcheck
		success("One-time commands executed")
	} else {
		info("Skipped one-time commands")
	}
}

// ─── Systemd units ─────────────────────────────────────────────────────────────

func (c *Config) enableSystemdUnits() {
	unitDir := filepath.Join(c.DotfilesDir, "specific/arch/base/.config/systemd/user")
	entries, err := os.ReadDir(unitDir)
	if err != nil {
		return
	}

	var units []string
	for _, e := range entries {
		name := e.Name()
		if strings.HasSuffix(name, ".service") || strings.HasSuffix(name, ".timer") {
			units = append(units, name)
		}
	}
	if len(units) == 0 {
		return
	}

	header("Systemd User Units")
	info(fmt.Sprintf("Found %d user units that can be enabled", len(units)))

	var choice string
	checkAbort(huh.NewSelect[string]().
		Options(
			huh.NewOption("Enable all units", "all"),
			huh.NewOption("Select units to enable", "select"),
			huh.NewOption("Skip", "skip"),
			huh.NewOption("Quit", "quit"),
		).
		Value(&choice).
		Run())
	if choice == "quit" {
		quit()
	}

	enableUnit := func(unit string) {
		err := c.runCmd("systemctl", "--user", "enable", "--now", unit)
		if err != nil {
			warn(unit + " (may need dependencies)")
		} else {
			success(unit)
		}
	}

	switch choice {
	case "all":
		for _, unit := range units {
			enableUnit(unit)
		}
	case "select":
		options := make([]huh.Option[string], 0, len(units))
		for _, u := range units {
			options = append(options, huh.NewOption(u, u))
		}
		var selected []string
		checkAbort(huh.NewMultiSelect[string]().
			Title("Select units to enable").
			Options(options...).
			Value(&selected).
			Height(20).
			Run())
		for _, unit := range selected {
			enableUnit(unit)
		}
	case "skip":
		info("Skipped systemd units")
	}
}

// ─── Prompt helpers ────────────────────────────────────────────────────────────

func selectStowAction(label string, pkgs []string) (string, []string) {
	var choice string
	checkAbort(huh.NewSelect[string]().
		Options(
			huh.NewOption("Stow all "+label+" packages", "all"),
			huh.NewOption("Select packages to stow", "select"),
			huh.NewOption("Skip "+label+" packages", "skip"),
			huh.NewOption("Quit", "quit"),
		).
		Value(&choice).
		Run())
	if choice == "quit" {
		quit()
	}

	switch choice {
	case "all":
		return "all", pkgs
	case "select":
		options := make([]huh.Option[string], 0, len(pkgs))
		for _, pkg := range pkgs {
			options = append(options, huh.NewOption(formatPackageOption(pkg), pkg))
		}
		var selected []string
		checkAbort(huh.NewMultiSelect[string]().
			Title("Select packages to stow").
			Options(options...).
			Value(&selected).
			Height(20).
			Run())
		return "select", selected
	default:
		return "skip", nil
	}
}

// ─── Banner ────────────────────────────────────────────────────────────────────

func printBanner(dryRun bool) {
	banner := lipgloss.NewStyle().
		Border(lipgloss.ThickBorder()).
		BorderForeground(lipgloss.Color("212")).
		Foreground(lipgloss.Color("212")).
		Padding(1, 4).
		MarginTop(1).
		MarginLeft(2).
		Bold(true)

	fmt.Println(banner.Render(strings.Join([]string{
		" ╺┳┓  ┏━┓ ╺┳╸ ┏━╸ ╻  ╻  ┏━╸ ┏━┓",
		"  ┃┃  ┃ ┃  ┃  ┣╸  ┃  ┃  ┣╸  ┗━┓",
		" ╺┻┛  ┗━┛  ╹  ╹   ╹  ┗━╸┗━╸ ┗━┛",
		"",
		"  khaosdoctor/dotfiles installer",
	}, "\n")))

	if dryRun {
		dryStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("14")).
			Bold(true).
			MarginLeft(2)
		fmt.Println(dryStyle.Render("  DRY RUN MODE -- no changes will be made"))
	}
}

// ─── Main ──────────────────────────────────────────────────────────────────────

func main() {
	dryRun := flag.Bool("dry-run", false, "Show what would be done without making changes")
	dryRunShort := flag.Bool("n", false, "Short for --dry-run")
	flag.Parse()

	cfg := &Config{
		DryRun: *dryRun || *dryRunShort,
	}

	// Find dotfiles dir (parent of installer/)
	exe, _ := os.Executable()
	cfg.DotfilesDir = filepath.Dir(filepath.Dir(exe))

	// Fallback: if running via `go run`, use working directory heuristic
	if _, err := os.Stat(filepath.Join(cfg.DotfilesDir, "general")); os.IsNotExist(err) {
		wd, _ := os.Getwd()
		// Check if we're in installer/ subdir
		if _, err := os.Stat(filepath.Join(wd, "general")); err == nil {
			cfg.DotfilesDir = wd
		} else if _, err := os.Stat(filepath.Join(filepath.Dir(wd), "general")); err == nil {
			cfg.DotfilesDir = filepath.Dir(wd)
		}
	}

	// Detect platform
	platform, err := detectPlatform()
	if err != nil {
		errMsg(err.Error())
		os.Exit(1)
	}
	cfg.Platform = platform

	// ── UI ──
	fmt.Print("\033[H\033[2J") // clear screen
	printBanner(cfg.DryRun)

	success("Detected platform: " + cfg.Platform)

	if err := checkPrerequisites(cfg.Platform); err != nil {
		os.Exit(1)
	}

	// ── Installation mode + dry-run toggle ──
	header("Installation Mode")
	var installMode string
	var dryRunToggle bool

	checkAbort(huh.NewForm(
		huh.NewGroup(
			huh.NewSelect[string]().
				Title("What kind of setup is this?").
				Options(
					huh.NewOption("Fresh -- New system, install packages + stow configs", "fresh"),
					huh.NewOption("Existing -- System already set up, just stow/update configs", "existing"),
					huh.NewOption("Quit", "quit"),
				).
				Value(&installMode),
			huh.NewConfirm().
				Title("Dry run? (preview changes without applying)").
				Value(&dryRunToggle).
				Affirmative("Yes").
				Negative("No"),
		),
	).Run())

	if installMode == "quit" {
		quit()
	}
	if dryRunToggle {
		cfg.DryRun = true
		dryStyle := lipgloss.NewStyle().
			Foreground(lipgloss.Color("14")).
			Bold(true).
			MarginLeft(2)
		fmt.Println(dryStyle.Render("  DRY RUN MODE -- no changes will be made"))
	}

	// ── System packages (fresh only) ──
	if installMode == "fresh" {
		header("System Package Installation")
		if cfg.Platform == "arch" {
			cfg.installArchPackages()
		} else {
			cfg.installDarwinPackages()
		}
	}

	// ── General packages ──
	generalDir := filepath.Join(cfg.DotfilesDir, "general")
	generalPkgs, _ := listPackages(generalDir)

	header("General Packages", "(cross-platform configs)")
	info(fmt.Sprintf("Found %d general packages", len(generalPkgs)))

	action, selected := selectStowAction("general", generalPkgs)
	switch action {
	case "all", "select":
		if len(selected) > 0 {
			cfg.runStow(generalDir, selected)
		}
	case "skip":
		info("Skipped general packages")
	}

	// ── Platform packages ──
	specificDir := filepath.Join(cfg.DotfilesDir, "specific", cfg.Platform)
	if _, err := os.Stat(specificDir); err == nil {
		platformPkgs, _ := listPackages(specificDir)
		targets := loadStowTargets(specificDir)

		header("Platform Packages", "("+cfg.Platform+"-specific configs)")
		info(fmt.Sprintf("Found %d %s-specific packages", len(platformPkgs), cfg.Platform))

		// Warn about sudo packages
		var sudoPkgs []string
		for _, pkg := range platformPkgs {
			if needsSudo(targets, pkg) {
				sudoPkgs = append(sudoPkgs, pkg)
			}
		}
		if len(sudoPkgs) > 0 {
			warn("These packages require sudo: " + strings.Join(sudoPkgs, ", "))
		}

		action, selected := selectStowAction(cfg.Platform, platformPkgs)
		switch action {
		case "all", "select":
			if len(selected) > 0 {
				cfg.runStow(specificDir, selected)
			}
		case "skip":
			info("Skipped " + cfg.Platform + " packages")
		}
	}

	// ── Post-install ──
	if cfg.Platform == "darwin" {
		cfg.runDarwinOneTime()
	} else if cfg.Platform == "arch" {
		cfg.enableSystemdUnits()
	}

	// ── Done ──
	fmt.Println()
	if cfg.DryRun {
		box := lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color("14")).
			Foreground(lipgloss.Color("14")).
			Padding(1, 3).
			MarginLeft(2).
			Bold(true)

		fmt.Println(box.Render(fmt.Sprintf(
			"Dry run complete! (%d commands would be executed)\n\nNo changes were made. Run without --dry-run to apply.",
			len(cfg.DryRunLog))))

		if len(cfg.DryRunLog) > 0 {
			fmt.Println()
			titleStyle := lipgloss.NewStyle().
				Foreground(lipgloss.Color("14")).
				Bold(true).
				MarginLeft(2)
			fmt.Println(titleStyle.Render("Commands that would run:"))
			for _, cmd := range cfg.DryRunLog {
				fmt.Println("  " + cmd)
			}
		}
	} else {
		box := lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color("46")).
			Foreground(lipgloss.Color("46")).
			Padding(1, 3).
			MarginLeft(2).
			Bold(true)

		fmt.Println(box.Render(strings.Join([]string{
			"All done!",
			"",
			"You may want to:",
			"  - Restart your shell (exec zsh)",
			"  - Log out and back in for systemd/DE changes",
			"  - Check specific/arch/README.md for theme setup notes",
		}, "\n")))
	}
}
