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

# JavaScript / TypeScript toolchain
# bun is the primary runtime + package manager; pnpm is the fallback package
# manager; node provides npm (used for global CLIs like Codex and Vite).
tap "oven-sh/bun"
brew "oven-sh/bun/bun" # JavaScript runtime and package manager (primary)
brew "pnpm"       # Fast, disk-efficient package manager (fallback)
brew "node"       # Node.js + npm (for global CLI tooling)
brew "nvm"        # Node version manager

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
