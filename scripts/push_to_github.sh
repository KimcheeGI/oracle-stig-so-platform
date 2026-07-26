#!/bin/bash
# Push repository to GitHub. Usage:
# ./scripts/push_to_github.sh <remote_repo_url> [branch]
# Example: ./scripts/push_to_github.sh git@github.com:kimcheegi/oracle-stig-so-platform.git main

set -euo pipefail

REMOTE_URL="${1:-}"
BRANCH="${2:-main}"

if [ -z "$REMOTE_URL" ]; then
  echo "Usage: $0 <remote_repo_url> [branch]"
  exit 2
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required. Install git and retry."
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -d .git ]; then
  git init
  echo "Initialized a new git repository"
fi

git add --all
git commit -m "Initial commit: portable Oracle Linux Ansible controller + Security Onion tooling" || true

if git remote | grep -q origin; then
  git remote remove origin
fi
git remote add origin "$REMOTE_URL"

echo "Pushing to $REMOTE_URL (branch: $BRANCH). Use SSH keys or a Personal Access Token for HTTPS authentication."
git push -u origin "$BRANCH"

echo "Push complete. Verify the repo on GitHub."
