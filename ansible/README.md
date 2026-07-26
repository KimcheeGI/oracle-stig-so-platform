This folder contains Ansible playbooks and roles.

Main files:
- `controller.yml`: prepares the Oracle Linux controller VM (installs Ansible, users, offline asset import)
- `securityonion.yml`: deploys Security Onion nodes (assumes target is Ubuntu) using offline assets when available

Customize `ansible/vars.yml` for environment-specific values.
