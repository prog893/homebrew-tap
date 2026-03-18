# prog893/homebrew-tap

Homebrew tap for prog893 CLI tools.

> **⚠️ Private Repository**
>
> This tap repository is **private** and requires GitHub authentication to access.
>
> **Setup is required** before tapping — see instructions below.

## Prerequisites

Before tapping this repository, you need to authenticate with GitHub:

### Option 1: GitHub CLI (Recommended)

```bash
# 1. Install GitHub CLI
brew install gh

# 2. Authenticate
gh auth login

# 3. Configure git to use gh for credentials
git config --global credential.https://github.com.helper '!/opt/homebrew/bin/gh auth git-credential'
```

### Option 2: Personal Access Token

```bash
# 1. Create PAT at: https://github.com/settings/tokens
#    Scope: `repo` (for private repos)

# 2. Configure git credential store
git config --global credential.helper store

# 3. Tap will prompt for credentials (saved after first use)
brew tap prog893/tap
```

## Install

```bash
brew tap prog893/tap
brew install prog893/tap/staqan-yt
```

## Tools

| Formula   | Description                             |
|-----------|-----------------------------------------|
| staqan-yt | YouTube metadata CLI (YouTube Data API) |

## Usage

```bash
# Install a tool
brew install prog893/tap/staqan-yt

# Upgrade
brew update && brew upgrade staqan-yt

# Uninstall
brew uninstall staqan-yt
```

## Adding a tool

See [CLAUDE.md](CLAUDE.md) for onboarding instructions.
