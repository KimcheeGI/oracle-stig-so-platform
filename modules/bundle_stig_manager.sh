#!/bin/bash
# Create a bundled tarball containing evaluate-stig + stig-manager roles and any required plugins
set -euo pipefail

OUT=stig-bundle.tar.gz
TMPDIR=$(mktemp -d)

mkdir -p "$TMPDIR/roles"
ansible-galaxy install -r ansible/requirements.yml -p "$TMPDIR/roles"

tar -czf "$OUT" -C "$TMPDIR" .
mv "$OUT" .
rm -rf "$TMPDIR"
echo "Created $OUT"
