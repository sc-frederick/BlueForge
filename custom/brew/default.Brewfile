# Default Brewfile for bluepilot
# Add your favorite brew packages here
# 
# Examples:

# Modern CLI tools
brew "bat"        # cat with syntax highlighting
brew "eza"        # Modern replacement for ls
brew "fd"         # Simple, fast alternative to find
brew "rg"         # ripgrep - faster grep

# Development tools
brew "gh"         # GitHub CLI
brew "git"        # Git version control
brew "neovim"     # Neovim text editor

# JavaScript / TypeScript: handled by Vite+ (vp), not Homebrew. Vite+ manages the
# runtime (Node), the per-project package manager, and the frontend toolchain
# (Vite, Vitest, Oxlint, Oxfmt, Rolldown, tsdown) from one CLI — so node/npm come
# from vp too, no separate Homebrew Node needed.
# Install with:  ujust install-vite-plus   (or  ujust setup-js-tooling  for Codex too)

# AI coding tools
tap "anomalyco/tap"
brew "anomalyco/tap/opencode" # OpenCode CLI assistant
cask "claude-code" # Anthropic CLI assistant
# Note: OpenAI Codex CLI is macOS-only on Homebrew (cask), so it is installed
# via npm by `ujust install-codex` (and `ujust setup-js-tooling`) instead.

# Shell enhancements  
brew "starship"   # Cross-shell prompt

# Utilities
brew "btop"       # Interactive process viewer
brew "tmux"       # Terminal multiplexer
