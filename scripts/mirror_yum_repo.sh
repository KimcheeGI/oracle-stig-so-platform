#!/bin/bash
# Mirror an Oracle/RHEL-compatible YUM/DNF repository for offline use.
# Requires: yum-utils (reposync) or dnf-plugins-core (dnf download).
set -euo pipefail

OUT_DIR="${1:-./yum-mirror}"
REPO_ID="${2:-ol8_base}" # repo id from /etc/yum.repos.d or repo URL

mkdir -p "$OUT_DIR"

if command -v reposync >/dev/null 2>&1; then
  echo "Using reposync to mirror repo id '$REPO_ID' into $OUT_DIR"
  reposync -r "$REPO_ID" -p "$OUT_DIR" --download-metadata
elif command -v dnf >/dev/null 2>&1; then
  echo "Using dnf to download packages listed in repo '$REPO_ID'"
  mkdir -p "$OUT_DIR/packages"
  repoquery --repoid="$REPO_ID" --qf "%{name}-%{version}-%{release}.%{arch}.rpm" | xargs -I{} dnf download --repo="$REPO_ID" --alldeps -y -q -x '*' -o "$OUT_DIR/packages/"
else
  echo "Please install yum-utils (reposync) or ensure dnf is available."
  exit 2
fi

echo "Generating repo metadata with createrepo_c"
if ! command -v createrepo_c >/dev/null 2>&1; then
  echo "Please install createrepo_c to generate repository metadata."
  exit 2
fi

createrepo_c "$OUT_DIR"

echo "YUM mirror prepared at: $OUT_DIR"
