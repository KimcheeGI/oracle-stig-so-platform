#!/bin/bash
# Prepare a local Security Onion apt repository from downloaded .deb files.
# Place Security Onion .deb packages into the <deb_dir> and this script will create a local repo.
set -euo pipefail

DEB_DIR="${1:-./so-debs}"
OUT_DIR="${2:-./so-apt-repo}"

if [ ! -d "$DEB_DIR" ]; then
  echo "Deb directory '$DEB_DIR' does not exist. Place .deb files there first." >&2
  exit 2
fi

mkdir -p "$OUT_DIR/pool"
cp -a "$DEB_DIR"/* "$OUT_DIR/pool/" || true

if ! command -v dpkg-scanpackages >/dev/null 2>&1; then
  echo "Installing dpkg-dev is required to run dpkg-scanpackages." >&2
  exit 2
fi

cd "$OUT_DIR"
dpkg-scanpackages pool /dev/null | gzip -9c > dists/stable/main/binary-amd64/Packages.gz || true

echo "Local Security Onion apt repo prepared at $OUT_DIR"
echo "Serve this directory via HTTP and add 'deb [trusted=yes] http://<server>/ ./'' to clients' sources.list"
