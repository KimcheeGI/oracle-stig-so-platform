#!/bin/bash
# Mirror an Ubuntu APT repository or Security Onion repo for offline use.
# Requires: debmirror or apt-mirror
set -euo pipefail

OUT_DIR="${1:-./apt-mirror}"
DIST="${2:-focal}"   # distribution e.g., focal, jammy
ARCH="${3:-amd64}"
MIRROR_URL="${4:-http://archive.ubuntu.com/ubuntu}"

mkdir -p "$OUT_DIR"

if command -v debmirror >/dev/null 2>&1; then
  echo "Using debmirror to mirror $MIRROR_URL $DIST ($ARCH) into $OUT_DIR"
  debmirror -a "$ARCH" -h "$(echo $MIRROR_URL | awk -F/ '{print $3}')" -d "$DIST" -r "/${DIST}" --method=http "$OUT_DIR"
elif command -v apt-mirror >/dev/null 2>&1; then
  echo "Using apt-mirror placeholder config"
  echo "set base_path    $OUT_DIR" > "$OUT_DIR/apt-mirror.list"
  echo "deb $MIRROR_URL $DIST main restricted universe multiverse" >> "$OUT_DIR/apt-mirror.list"
  apt-mirror "$OUT_DIR/apt-mirror.list"
else
  echo "Please install debmirror or apt-mirror to mirror APT repositories."
  exit 2
fi

echo "APT mirror prepared at: $OUT_DIR"
