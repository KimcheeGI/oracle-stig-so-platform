# Offline Repository Preparation

This document describes how to prepare offline package repositories used by the Ansible controller and Security Onion deployment.

Steps overview

- Mirror Oracle/EL packages (YUM/DNF): run `scripts/mirror_yum_repo.sh` with the repo id or destination.
- Mirror Ubuntu/Debian packages (APT): run `scripts/mirror_apt_repo.sh` for the desired distribution.
- Prepare Security Onion local repo: place the `.deb` packages in a folder and run `scripts/prepare_so_repo.sh` to build a simple apt repository structure.

Serving the repos

Serve the generated directories via a simple HTTP server on the controller (example):

```bash
python3 -m http.server --directory /var/local/so-apt-repo 8000
```

Then add to client `/etc/apt/sources.list` or `yum.repos.d` pointing at the controller's URL.

Notes and caveats

- Mirroring large repositories may require tens or hundreds of GBs of storage.
- Oracle Linux / RHEL repositories may require a subscription or credentials; use a mirror you are entitled to.
- Security Onion releases and their packaging policies change; prefer to capture the exact packages used by the version you plan to deploy.
