# Executive Readiness Checklist

Use this checklist to decide whether the Oracle Linux STIG controller image is ready for Azure publication and cross-tenant use.

## Scope and Decision

- [ ] Confirm deployment model:
  - [ ] Public Azure (connected)
  - [ ] Public Azure (restricted egress)
  - [ ] Disconnected platform (Azure Stack Hub / Azure Local)
- [ ] Confirm this image is intended for cross-tenant distribution.
- [ ] Confirm data classification and handling requirements.

## Governance and Risk

- [ ] Business owner assigned.
- [ ] Security owner assigned.
- [ ] Platform owner assigned.
- [ ] Risk register updated for image distribution.
- [ ] Exception process documented (if any controls are deferred).

## Security and Compliance

- [ ] No hardcoded credentials in source repo.
- [ ] Secrets managed in approved secret store.
- [ ] Baseline hardening validated on Azure VM.
- [ ] Root access policy documented (break-glass only).
- [ ] Audit evidence collection path approved.
- [ ] Retention policy approved for logs and compliance reports.

## Financial and Operational Readiness

- [ ] Cost center and chargeback model defined.
- [ ] Region strategy approved.
- [ ] DR/rollback strategy approved.
- [ ] Patch cadence approved.
- [ ] Support model approved (L1/L2/L3 ownership).

## Cross-Tenant Distribution Approval

- [ ] Source tenant and target tenant IDs documented.
- [ ] Legal/commercial approval for image sharing complete.
- [ ] RBAC model approved.
- [ ] Image lifecycle/deprecation policy approved.

## Go/No-Go Gates

- [ ] Gate 1: Security sign-off
- [ ] Gate 2: Platform sign-off
- [ ] Gate 3: Compliance sign-off
- [ ] Gate 4: Operations sign-off
- [ ] Final release approval recorded

## Sign-off Record

- Sponsor: ____________________ Date: __________
- Security: ___________________ Date: __________
- Platform: ___________________ Date: __________
- Compliance: _________________ Date: __________
- Operations: _________________ Date: __________
