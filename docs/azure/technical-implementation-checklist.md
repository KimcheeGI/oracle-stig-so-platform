# Technical Implementation Checklist

Use this checklist to build, publish, validate, and operate the image in Azure.

## 1. Prerequisites

- [ ] Azure subscriptions identified (build and runtime).
- [ ] Source and destination tenant IDs documented.
- [ ] Required roles granted (subscription/resource-group/image operations).
- [ ] Resource naming and tagging standards applied.
- [ ] Build identity/service principal configured.

## 2. Image Build Strategy

- [ ] Choose image source path:
  - [ ] Azure-native Packer build (recommended)
  - [ ] VMware VMDK/OVA conversion to Azure VHD
- [ ] Packer template parameterized for all secrets.
- [ ] Secrets loaded from non-committed var file or secret manager.
- [ ] Kickstart/cloud-init has no plaintext secrets.
- [ ] Build logs and artifacts retained in controlled storage.

## 3. Build and Validate Base Image

- [ ] Build image successfully.
- [ ] Validate VM boot and SSH access.
- [ ] Validate controller services:
  - [ ] Python
  - [ ] Ansible
  - [ ] nginx (if required)
- [ ] Validate STIG workflow preconditions.
- [ ] Run smoke tests and capture evidence.

## 4. Azure Compute Gallery Publication

- [ ] Create gallery.
- [ ] Create image definition (publisher/offer/sku/hyper-v generation).
- [ ] Publish first image version.
- [ ] Replicate image to required regions.
- [ ] Validate region-specific deployment.

## 5. Cross-Tenant Access

- [ ] Configure gallery sharing model.
- [ ] Assign RBAC for target tenant principals.
- [ ] Confirm target tenant can list image versions.
- [ ] Confirm target tenant can deploy VM from shared image.

## 6. Restricted Egress / Offline-Style Controls

- [ ] No public IP on VM.
- [ ] Outbound internet blocked via NSG/Firewall/UDR policy.
- [ ] Private endpoints used where applicable.
- [ ] Offline assets preloaded and reachable.
- [ ] Package/repo workflow validated without internet.

## 7. Security Controls

- [ ] Root SSH policy applied per standard.
- [ ] Local admin and break-glass account policy documented.
- [ ] Certificates and key material rotated from defaults.
- [ ] Secrets redacted from logs.
- [ ] Defender/SIEM telemetry validated.

## 8. Operational Readiness

- [ ] Monitoring and alerts configured.
- [ ] Backup/snapshot policy configured.
- [ ] Patch/update pipeline defined.
- [ ] Rollback to prior image version tested.
- [ ] Incident response runbook linked.

## 9. Evidence Package

- [ ] Build logs archived.
- [ ] Test results archived.
- [ ] Security validation results archived.
- [ ] Change record and approvals archived.

## 10. Exit Criteria

- [ ] Successful deployment in source tenant.
- [ ] Successful deployment in at least one destination tenant.
- [ ] Security and compliance checks pass.
- [ ] Operations handoff complete.
