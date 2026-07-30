#!/bin/bash
set -e

echo "=== Step 1: Mount ISO and configure local DNF repo ==="
mount /dev/sr0 /mnt 2>/dev/null || echo "ISO already mounted or not present"

cat > /etc/yum.repos.d/ol9-local.repo << 'REPO'
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
REPO

dnf config-manager --disable ol9_baseos_latest ol9_appstream ol9_UEKR7 ol9_developer_EPEL 2>/dev/null || true

echo "=== Step 2: Install required packages ==="
dnf install -y --nogpgcheck nginx httpd-tools openssl policycoreutils-python-utils unzip git

echo "=== Step 3: Install Galaxy roles (offline only) ==="
cd /opt/oracle-stig/ansible
ansible-galaxy install -r requirements.yml --ignore-errors 2>/dev/null || true

echo "=== Step 4: Run controller playbook ==="
ansible-playbook controller.yml -v
