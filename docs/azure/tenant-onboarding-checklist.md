# Tenant Onboarding Checklist

Use this checklist for each destination tenant that will consume the shared image.

## 1. Intake

- [ ] Tenant name and tenant ID collected.
- [ ] Subscription ID(s) collected.
- [ ] Primary contact and technical contact assigned.
- [ ] Intended environment documented (dev/test/prod).

## 2. Access and Permissions

- [ ] Required RBAC roles granted in destination subscription.
- [ ] Access to source Azure Compute Gallery confirmed.
- [ ] Image definition and version visibility confirmed.
- [ ] Network and policy prerequisites validated.

## 3. Deployment Readiness

- [ ] Region selected and approved.
- [ ] VM size selected and approved.
- [ ] Virtual network/subnet selected.
- [ ] NSG/Firewall baseline attached.
- [ ] No-public-IP requirement applied (if required).

## 4. Security Initialization

- [ ] Replace all default credentials on first boot.
- [ ] Confirm root access policy and disable direct root SSH if required.
- [ ] Configure break-glass workflow.
- [ ] Rotate certificates/keys from any defaults.

## 5. Functional Validation

- [ ] VM deploy succeeds from shared image.
- [ ] SSH access works with approved account.
- [ ] Ansible controller checks pass.
- [ ] Offline asset path checks pass.
- [ ] Logging/monitoring data appears in destination tenant tools.

## 6. Compliance Validation

- [ ] STIG/hardening controls validated for tenant policy.
- [ ] Evidence output path validated.
- [ ] Retention and audit requirements validated.
- [ ] Exceptions documented and approved.

## 7. Handover

- [ ] Runbook delivered.
- [ ] Support escalation path documented.
- [ ] Update schedule documented.
- [ ] Owner acceptance completed.

## 8. Per-Tenant Record

- Tenant: ______________________________
- Subscription: _________________________
- Region: ______________________________
- Image version: _______________________
- Date onboarded: ______________________
- Approved by: _________________________
