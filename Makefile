# macOS Rice Configuration Makefile

# Default target
help: ## Show this help message
	@echo "macOS Rice Configuration"
	@echo "=========================="
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Full installation (build + switch)
	@echo "Starting full installation..."
	@$(MAKE) switch

verify: ## Verify current configuration and services
	@echo "🔍 Verifying current setup..."
	@$(MAKE) info
	@$(MAKE) test

build: ## Build the nix-darwin configuration
	@echo "🔨 Building configuration..."
	@nix --experimental-features "nix-command flakes" build ".#darwinConfigurations.simple.system"

switch: build ## Build and switch to new configuration
	@echo "🔄 Switching to new configuration..."
	@sudo ./result/sw/bin/darwin-rebuild switch --flake .#simple

build-fallback: ## Build with fallback (builds from source if cache fails)
	@echo "🔨 Building configuration (with fallback)..."
	@nix --experimental-features "nix-command flakes" build ".#darwinConfigurations.simple.system" --fallback

switch-fallback: build-fallback ## Build and switch with fallback
	@echo "🔄 Switching to new configuration..."
	@sudo ./result/sw/bin/darwin-rebuild switch --flake .#simple

clean: ## Clean up nix store and build artifacts
	@echo "🧹 Cleaning up..."
	@nix-collect-garbage -d
	@rm -rf result

update: ## Update flake inputs and rebuild
	@echo "🔄 Updating flake inputs..."
	@nix flake update
	@$(MAKE) switch

check: ## Check configuration for errors
	@echo "🔍 Checking configuration..."
	@nix --experimental-features "nix-command flakes" flake check

format: ## Format nix files
	@echo "🎨 Formatting nix files..."
	@find . -name "*.nix" -exec nixpkgs-fmt {} \;

permissions: ## Set up required permissions (requires manual action)
	@echo "🔐 Setting up permissions..."
	@echo "Please manually add the following to System Preferences:"
	@echo "  1. Security & Privacy → Privacy → Accessibility → Add Terminal/yabai"
	@echo "  Note: SketchyBar screen recording permission not needed (SketchyBar disabled)"
	@open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

info: ## Show system information
	@echo "📋 System Information"
	@echo "==================="
	@echo "Nix version: $$(nix --version)"
	@echo "Darwin generation: $$(darwin-rebuild --version 2>/dev/null || echo 'Not installed')"
	@echo "Homebrew version: $$(brew --version | head -1)"
	@echo ""

test: ## Test hotkeys and configuration
	@echo "🧪 Testing Configuration"
	@echo "========================"
	@echo "Testing window manager..."
	@yabai -m query --spaces > /dev/null 2>&1 && echo "✅ yabai permissions OK" || echo "❌ yabai needs accessibility permissions"
	@echo "Testing hotkey daemon..."
	@pgrep skhd > /dev/null && echo "✅ skhd running" || echo "❌ skhd not running"
	@echo "Testing finder shortcut..."
	@test -x ~/.config/skhd/finder-goto.sh && echo "✅ finder-goto.sh executable" || echo "❌ finder-goto.sh missing/not executable"
	@echo "Testing skhd config syntax..."
	@skhd -t ~/.config/skhd/skhdrc > /dev/null 2>&1 && echo "✅ skhd config syntax OK" || echo "❌ skhd config has syntax errors"
	@echo ""
	@echo "🎮 Try these hotkeys:"
	@echo "  Alt+H/J/K/L     - Navigate windows"
	@echo "  Shift+Alt+Space - Toggle float"
	@echo "  Ctrl+Alt+A      - BSP layout"
	@echo "  Alt+/           - Finder Go To Folder (Global)"

status: ## Show detailed system status
	@echo "📊 Detailed System Status"
	@echo "========================="
	@echo "🔧 Services:"
	@echo "  yabai: $$(pgrep yabai > /dev/null && echo '✅ running (PID: '`pgrep yabai`')' || echo '❌ stopped')"
	@echo "  skhd:  $$(pgrep skhd > /dev/null && echo '✅ running (PID: '`pgrep skhd`')' || echo '❌ stopped')"
	@echo ""
	@echo "📁 Configuration Files:"
	@echo "  yabai config: $$(test -f ~/.config/yabai/yabairc && echo '✅ present' || echo '❌ missing')"
	@echo "  skhd config:  $$(test -f ~/.config/skhd/skhdrc && echo '✅ present' || echo '❌ missing')"
	@echo "  finder script: $$(test -x ~/.config/skhd/finder-goto.sh && echo '✅ present & executable' || echo '❌ missing/not executable')"
	@echo ""
	@echo "🎨 Window Manager Settings:"
	@echo "  Layout: $$(yabai -m config layout 2>/dev/null || echo 'N/A')"
	@echo "  Transparency: $$(yabai -m config normal_window_opacity 2>/dev/null || echo 'N/A')"
	@echo "  Animation Duration: $$(yabai -m config window_animation_duration 2>/dev/null || echo 'N/A')s"
	@echo "  Border Width: $$(yabai -m config window_border_width 2>/dev/null || echo 'N/A')px"

logs: ## Show service logs
	@echo "📝 Service Logs"
	@echo "=============="
	@echo "--- yabai logs ---"
	@tail -10 /opt/homebrew/var/log/yabai/yabai.out.log 2>/dev/null || echo "No yabai logs found"
	@echo ""
	@echo "--- skhd logs ---"
	@tail -10 /opt/homebrew/var/log/skhd/skhd.out.log 2>/dev/null || echo "No skhd logs found"

backup: ## Create backup of current configuration
	@echo "💾 Creating backup..."
	@tar -czf "backup-$$(date +%Y%m%d-%H%M%S).tar.gz" --exclude="result" --exclude="*.tar.gz" .
	@echo "Backup created: backup-$$(date +%Y%m%d-%H%M%S).tar.gz"

.PHONY: help install build switch clean restart-all restart-yabai restart-skhd restart-sketchybar update nixup check format permissions info test status logs backup setup-gemini test-gemini gemini-help