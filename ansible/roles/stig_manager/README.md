Ansible role: stig_manager

Purpose
- Copy bundled Ansible roles from `/opt/offline-assets/roles` into the system roles path and run `evaluate-stig` and `stig-manager` roles when present.

Usage
- Include this role in a play targeting the controller (it's already wired into `ansible/controller.yml`).

Variables (defaults defined in `defaults/main.yml`)
- `stig_manager_run_evaluate`: whether to run `evaluate-stig` automatically (default: true)
