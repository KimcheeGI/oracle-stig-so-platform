# Oracle Linux Ansible Controller + Security Onion Deployment

This repo builds a portable Oracle Linux 9 VM (VMware Workstation) acting as an Ansible controller that bundles `evaluate-stig` and `stig-manager`, and can deploy Security Onion IDS/IPS into new environments. The solution is designed to be self-sufficient in closed/air-gapped networks.

```
packer/         Packer template + kickstart to build the Oracle Linux VM
ansible/        Playbooks, roles, and requirements for controller and Security Onion
scripts/        Helper scripts: gather offline assets, export OVA
modules/        Packaging/bundling scripts for evaluate-stig & stig-manager
tests/          Test harness
```

---

## Requirements

| Tool | Version | Notes |
|------|---------|-------|
| Packer | ≥ 1.16 | with `github.com/hashicorp/vmware` plugin ≥ 1.0.0 |
| VMware Workstation | 17.5+ | Windows host supported |
| Oracle Linux 9.8 ISO | — | `C:/ISOs/OracleLinux-R9-U8-x86_64-dvd.iso` |
| Ansible | 2.15+ | installed inside the VM by kickstart |
| ovftool | optional | for OVA export |

---

## Build the VM with Packer

The Packer build is fully automated via kickstart (`packer/ks.cfg`). No GUI interaction required.

```powershell
cd packer
packer init .
packer build -force ol-packer.pkr.hcl
```

**What happens:**
1. Packer creates a VMware VM (4 GB RAM, 2 vCPU, 40 GB disk, BIOS/isolinux)
2. Boots the Oracle Linux 9.8 ISO and injects `inst.ks=http://<host>:<port>/ks.cfg` via VNC
3. Anaconda performs a fully unattended install (~13–20 min)
4. Packer SSHs in as `root` to run verification, then shuts down and compacts disk
5. VM artifacts saved to `packer/output-oracle_linux/`

**VM credentials (set in kickstart):**
- `root` / `CyberSecurity123!`
- `ansible` / `CyberSecurity123!` (passwordless sudo)

> **Note:** The Packer build targets **BIOS mode** (`firmware = "bios"`). The `boot_wait` is set to `10s` — this must be shorter than the 60-second isolinux menu countdown.

---

## Manual Intervention Steps

After the Packer build completes and you have powered on the VM in VMware Workstation, the following steps are required to complete the full controller setup.

### 1. Re-attach the ISO for package installation

Packer detaches the ISO at the end of the build. nginx and httpd-tools must be installed from a repo.

**Option A — Use internet repos (if VM has internet access):**
```bash
dnf install -y nginx httpd-tools
```

**Option B — Use the DVD ISO as a local repo (air-gapped):**
1. In VMware Workstation: right-click VM → **Settings** → **CD/DVD (IDE)** → select `C:\ISOs\OracleLinux-R9-U8-x86_64-dvd.iso` → check **Connected** → **OK**
2. Reboot the VM (required for the kernel to detect new media)
3. On the VM:
```bash
mount /dev/sr0 /mnt
cat > /etc/yum.repos.d/ol9-local.repo << 'EOF'
[ol9-local-baseos]
name=Oracle Linux 9 BaseOS (Local ISO)
baseurl=file:///mnt/BaseOS
enabled=1
gpgcheck=0

[ol9-local-appstream]
name=Oracle Linux 9 AppStream (Local ISO)
baseurl=file:///mnt/AppStream
enabled=1
gpgcheck=0
EOF
dnf config-manager --disable ol9_baseos_latest ol9_appstream ol9_UEKR7 2>/dev/null || true
dnf install -y nginx httpd-tools
```

### 2. Copy the Ansible project to the VM

From Windows (PowerShell):
```powershell
# Generate SSH key for passwordless access (one-time)
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\ol-controller" -N ""

# On the VM console, authorize the key:
# mkdir -p ~/.ssh && echo "<pubkey>" >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys

$key = "$env:USERPROFILE\.ssh\ol-controller"
scp -i $key -o StrictHostKeyChecking=no -r .\ansible root@<VM_IP>:/opt/oracle-stig
```

> **Note:** VS Code integrated terminals cannot send keystrokes to interactive SSH password prompts. Use SSH key auth (above) or `sshpass` via WSL:
> ```bash
> sshpass -p 'CyberSecurity123!' scp -o StrictHostKeyChecking=no -r /mnt/c/Scripts/oracle-stig-so-platform/ansible root@<VM_IP>:/opt/oracle-stig
> ```

### 3. Install ansible.posix collection

The controller playbook requires the `ansible.posix` collection for the `firewalld` module:

```bash
ansible-galaxy collection install ansible.posix
```

### 4. Run the controller playbook

```bash
cd /opt/oracle-stig/ansible
ansible-playbook controller.yml -v
```

**Expected result:** `ok=25  changed=8  failed=0  skipped=12  ignored=1`

This configures:
- nginx HTTPS server for offline asset delivery (self-signed cert)
- htpasswd authentication for offline repo
- SELinux fcontext for `/opt/offline-assets`
- firewalld HTTPS rule
- ansible user and wheel group membership

### 5. (Optional) Add offline STIG assets

If you have an offline assets bundle:
```bash
mkdir -p /opt/offline-assets
cp assets.tar.gz /opt/offline-assets/
ansible-playbook controller.yml -v   # re-run to unpack and configure
```

---

## Deploy Security Onion

```bash
# Edit inventory first
vim ansible/inventory.ini

ansible-playbook ansible/securityonion.yml -i ansible/inventory.ini
```

---

## Export OVA

```bash
# VMware Workstation (ovftool)
./scripts/vmx_postprocess.sh packer/output-oracle_linux/ol-ansible-controller.vmx
ovftool --acceptAllEulas packer/output-oracle_linux/ol-ansible-controller.vmx ol-ansible-controller.ova

# ESXi (govc)
export GOVC_URL=... GOVC_USERNAME=... GOVC_PASSWORD=...
./scripts/export_ova_govc.sh "ol-ansible-controller" ./ol-ansible-controller.ova
```

---

## Known Issues & Notes

| Issue | Resolution |
|-------|-----------|
| `daviee.evaluate-stig` not found on Galaxy | Role does not exist publicly; requires offline bundle at `/opt/offline-assets/roles/` |
| `stig-manager` Galaxy role not found | Same — offline bundle required |
| Packer `boot_wait = "60s"` causes isolinux timeout | Fixed: `boot_wait = "10s"` with `firmware = "bios"` |
| SSH auth failure after install | Fixed: OL9 uses `/etc/ssh/sshd_config.d/` drop-ins; `01-packer.conf` injected via kickstart `%post` |
| `yum -y update` fails in Packer provisioner | Expected in air-gapped builds; packages pre-installed via kickstart `@core @standard @system-tools` |
| `import_role` with `when:` skips condition | Fixed: changed to `include_role` (runtime evaluation) |
| `lookup(...) is not failed` in `when:` | Fixed: replaced with `stat` module pre-checks |

---

## Credentials Reference

| Account | Password | Purpose |
|---------|----------|---------|
| root | CyberSecurity123! | VM root, Packer SSH |
| ansible | CyberSecurity123! | Ansible control user (passwordless sudo) |
| repouser | RepoPass123 | nginx offline repo basic auth |

> **Security note:** Change all default passwords before production use. Use `ansible-vault` for secrets in playbooks.

---

## Push to GitHub

```powershell
git add -A
git commit -m "your message"
git push origin main
```

---

## License

MIT

