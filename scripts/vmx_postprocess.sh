#!/bin/bash
# Minimal VMX post-processing helper for VMware Workstation before ovftool export
# Usage: vmx_postprocess.sh /path/to/vm.vmx
set -euo pipefail

VMX="$1"

if [ ! -f "$VMX" ]; then
  echo "VMX not found: $VMX"
  echo "Usage: $0 /path/to/vm.vmx"
  exit 2
fi

cp "$VMX" "$VMX.bak"

# Example adjustments: force bridged networking and remove snapshots reference
sed -i -E 's/ethernet0.connection = .*/ethernet0.connection = "bridged"/' "$VMX" || true
sed -i -E '/snapshot/Id/d' "$VMX" || true

echo "Post-processing complete. Backup saved to $VMX.bak"
echo "You can now export with ovftool:"
echo "  ovftool --acceptAllEulas \"$VMX\" output.ova"
