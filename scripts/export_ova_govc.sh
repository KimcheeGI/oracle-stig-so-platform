#!/bin/bash
# Export a VM on ESXi to OVA using govc
# Usage: export_ova_govc.sh <vm_name> <output.ova>
set -euo pipefail

VM_NAME="$1"
OUT="$2"

if [ -z "${VM_NAME:-}" ] || [ -z "${OUT:-}" ]; then
  echo "Usage: $0 <vm_name> <output.ova>"
  exit 2
fi

# govc requires GOVC_URL, GOVC_USERNAME, GOVC_PASSWORD and optional GOVC_INSECURE
echo "Exporting VM '$VM_NAME' to '$OUT' via govc..."
govc export.ova -vm "$VM_NAME" "$OUT"
echo "Export complete: $OUT"
