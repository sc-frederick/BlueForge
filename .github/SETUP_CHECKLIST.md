# Repository Setup Checklist

## Initial Setup

### 1. Rename Template
- [x] Update `finpilot` to your repository name (`blueforge`) in: Containerfile, Justfile, README.md, artifacthub-repo.yml, custom/ujust/README.md, .github/workflows/clean.yml

### 2. Enable GitHub Actions
- [x] Settings → Actions → General → Enable workflows
- [x] Set "Read and write permissions"
- [x] Confirm active workflows via `gh workflow list`

### 3. First Push
```bash
git add .
git commit -m "feat: initial customization"
git push origin main
```

### 4. Deploy
```bash
sudo bootc switch --transport registry ghcr.io/YOUR_USERNAME/YOUR_REPO:stable
sudo systemctl reboot
```

## Optional: Production Features

### Enable Signing (Recommended)
```bash
cosign generate-key-pair
# Add cosign.key to GitHub Secrets as SIGNING_SECRET
# Uncomment signing in .github/workflows/build.yml
# Trigger build: gh workflow run build.yml
# Verify runs: gh run list --workflow "Build container image" --limit 5
```
