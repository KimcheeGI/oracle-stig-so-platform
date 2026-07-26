#!/bin/bash
# Export a VMware VM to OVA using ovftool (VMware CLI)
set -euo pipefail

VMX_PATH="$1" # path to the .vmx file or vmuri
OUT_OVA="$2"  # path to output .ova

if [ -z "$VMX_PATH" ] || [ -z "$OUT_OVA" ]; then
  echo "Usage: $0 /path/to/vm.vmx /path/to/output.ova"
  exit 2
fi

echo "Exporting $VMX_PATH -> $OUT_OVA"
ovftool --acceptAllEulas "$VMX_PATH" "$OUT_OVA"
echo "Export complete"
