# Oracle Linux Ansible Controller + Security Onion Deployment

This repo builds a portable Oracle Linux VM (VMware) acting as an Ansible controller that bundles `evaluate-stig` and `stig-manager`, and can deploy Security Onion IDS/IPS into new environments. The solution is designed to be self-sufficient in closed networks.

Quick layout
- `packer/` — Packer template to build an Oracle Linux VM for VMware
- `ansible/` — playbooks, roles and requirements for controller and Security Onion deployment
- `scripts/` — helper scripts to gather offline assets and export OVA
- `modules/` — packaging/bundling scripts for evaluate-stig & stig-manager

See the playbooks for usage and customization.

Next steps
1. Edit `packer/ol-packer.pkr.hcl` to point to your Oracle Linux ISO and VMware builder settings.
2. Run Packer to build the VM, import into VMware, and export OVA with `scripts/export_ova.sh`.
3. Boot the VM, run the controller playbook to install Ansible and import offline assets.

Requirements
- Packer (with VMware builder plugin)
- Ansible 2.14+
- VMware Workstation / ESXi and `ovftool` for OVA export

License: MIT

Usage examples

- Build the VM with Packer (edit `iso_path` first):

```bash
cd packer
packer init .
packer build ol-packer.pkr.hcl
```

- Prepare offline assets (run on a machine with internet access):

```bash
./scripts/download_offline_assets.sh
# resulting bundle: offline-assets/assets.tar.gz
```

- Copy `offline-assets/assets.tar.gz` to the controller at `/opt/offline-assets/` before running the controller playbook.

- Configure controller and deploy Security Onion:

```bash
# on the controller VM
ansible-playbook ansible/controller.yml
ansible-playbook ansible/securityonion.yml -i ansible/inventory.ini
```

- Exporting OVA (Workstation/ovftool):

```bash
./scripts/vmx_postprocess.sh /path/to/vm.vmx
ovftool --acceptAllEulas /path/to/vm.vmx /path/to/output.ova
```

- Exporting OVA from ESXi (govc):

```bash
# set GOVC_URL, GOVC_USERNAME, GOVC_PASSWORD
./scripts/export_ova_govc.sh "ol-ansible-controller" ./ol-ansible-controller.ova
```

Files of interest
- `ansible/inventory.ini` — example inventory
- `ansible/credentials.example.yml` — example credentials (use ansible-vault)
- `scripts/export_ova_govc.sh` — ESXi export helper (govc)
- `scripts/vmx_postprocess.sh` — VMX helper for Workstation exports

Uploading to GitHub

To upload this workspace to your GitHub repository (for example `git@github.com:kimcheegi/oracle-stig-so-platform.git`), run:

```bash
./scripts/push_to_github.sh git@github.com:kimcheegi/oracle-stig-so-platform.git main
```

Notes:
- The script initializes a git repo if one is not present, commits all files, and pushes to the provided remote.
- Use SSH remote URLs if you have an SSH key configured, or an HTTPS remote and a Personal Access Token (PAT).
- Ensure secrets (vault passwords, `.vault_pass`, and `offline-assets`) are not present in the repo — check `.gitignore`.


Quick test (local)

```bash
# prepare prerequisites: packer, ansible, ovftool (optional)
# run the test harness which simulates build/export and validates controller
bash tests/test_harness.sh
```

