#!/bin/bash
# Download offline assets for Security Onion and Ansible roles
set -euo pipefail

OUT_DIR="$(pwd)/offline-assets"
mkdir -p "$OUT_DIR"

echo "Downloading Security Onion packages (placeholder)..."
# The following is a placeholder: users should download the Security Onion apt repo and images
echo "Place Security Onion apt repo in $OUT_DIR/so-apt-repo"

echo "Downloading Ansible Galaxy roles to $OUT_DIR/roles"
mkdir -p "$OUT_DIR/roles"
ansible-galaxy install -r ansible/requirements.yml -p "$OUT_DIR/roles"

echo "Bundling assets..."
tar -czf assets.tar.gz -C "$OUT_DIR" .
mv assets.tar.gz "$OUT_DIR/"

echo "Offline assets prepared at $OUT_DIR/assets.tar.gz"
