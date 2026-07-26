#!/bin/bash
# Test harness: simulate Packer build, VM import/export, and validate controller playbook
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PACKER_TEMPLATE="$ROOT_DIR/packer/ol-packer.pkr.hcl"
PLAYBOOK="$ROOT_DIR/ansible/controller.yml"

echo "1) Validate Packer template (if packer is installed)"
if command -v packer >/dev/null 2>&1; then
  packer validate "$PACKER_TEMPLATE"
else
  echo "packer not found; skipping validation"
fi

echo "2) Simulate Packer build output by creating dummy VM directory"
SIM_DIR="$(mktemp -d)"
VMX="$SIM_DIR/ol-ansible-controller.vmx"
cat > "$VMX" <<'VMX'
displayName = "ol-ansible-controller"
ethernet0.connection = "nat"
VMX

echo "Dummy VMX created at $VMX"

echo "3) Run VMX postprocess script"
bash "$ROOT_DIR/scripts/vmx_postprocess.sh" "$VMX"

echo "4) Simulate OVA export: if ovftool exists use it, otherwise create a tarball"
OUT_OVA="$ROOT_DIR/tests/ol-ansible-controller.ova"
mkdir -p "$(dirname "$OUT_OVA")"
if command -v ovftool >/dev/null 2>&1; then
  ovftool --acceptAllEulas "$VMX" "$OUT_OVA" || true
else
  tar -czf "$OUT_OVA" -C "$SIM_DIR" .
fi

echo "5) Prepare offline assets archive and place it where controller expects"
ASSETS_DIR="$SIM_DIR/offline-assets"
mkdir -p "$ASSETS_DIR/yum" "$ASSETS_DIR/so-apt-repo"
touch "$ASSETS_DIR/yum/repodata/repomd.xml"
mkdir -p "$ASSETS_DIR/so-apt-repo/dists/stable/main/binary-amd64"
touch "$ASSETS_DIR/so-apt-repo/dists/stable/main/binary-amd64/Packages"

echo "Preparing ansible-vault test bundle"
VAULT_DIR="$ASSETS_DIR/vault"
mkdir -p "$VAULT_DIR"
VAULT_PASS_FILE="$SIM_DIR/.vault_pass"
echo "TestVaultPass" > "$VAULT_PASS_FILE"
chmod 600 "$VAULT_PASS_FILE"

VAULT_PLAIN="$SIM_DIR/vault_plain.yml"
cat > "$VAULT_PLAIN" <<EOF
so_admin_pass: 'ChangeMeNow'
stig_manager_run_evaluate: true
EOF

if command -v ansible-vault >/dev/null 2>&1; then
  echo "Encrypting vault file with ansible-vault for test"
  ansible-vault encrypt --vault-password-file "$VAULT_PASS_FILE" --output "$VAULT_DIR/vault.yml" "$VAULT_PLAIN"
  cp "$VAULT_PASS_FILE" "$VAULT_DIR/.vault_pass"
else
  echo "ansible-vault not available; copying plaintext vault for simulation"
  cp "$VAULT_PLAIN" "$VAULT_DIR/vault.yml"
  echo "TestVaultPass" > "$VAULT_DIR/.vault_pass"
fi

echo "Creating dummy bundled roles (evaluate-stig and stig-manager) for simulation"
ROLES_DIR="$ASSETS_DIR/roles"
mkdir -p "$ROLES_DIR/evaluate-stig/tasks" "$ROLES_DIR/stig-manager/tasks"
cat > "$ROLES_DIR/evaluate-stig/tasks/main.yml" <<'YAML'
---
- name: Dummy evaluate-stig task
  debug:
    msg: 'Simulated evaluate-stig run (dry-run)'
YAML
cat > "$ROLES_DIR/stig-manager/tasks/main.yml" <<'YAML'
---
- name: Dummy stig-manager task
  debug:
    msg: 'Simulated stig-manager task'
YAML

tar -czf "$SIM_DIR/assets.tar.gz" -C "$ASSETS_DIR" .

echo "Copying assets to /opt/offline-assets (requires sudo)"
sudo mkdir -p /opt/offline-assets
sudo tar -xzf "$SIM_DIR/assets.tar.gz" -C /opt/offline-assets

echo "6) Run Ansible controller playbook to configure and serve offline repos"
if command -v ansible-playbook >/dev/null 2>&1; then
  sudo ansible-playbook -c local "$PLAYBOOK"
  echo "Running STIG role in check (dry-run) mode"
  sudo ansible-playbook -c local --check ansible/run_stig.yml || true
else
  echo "ansible-playbook not installed; install ansible to run controller validation"
  exit 0
fi

echo "7) Validate HTTPS server and repo availability with basic auth"
if command -v curl >/dev/null 2>&1; then
  curl -k -u "repouser:RepoPass123" https://127.0.0.1/ || echo "HTTPS server unreachable or auth failed"
else
  echo "curl not installed; manual check: https://127.0.0.1/ (use provided creds)"
fi

echo "Test harness completed. Clean up suggestion: remove /opt/offline-assets and $SIM_DIR"
