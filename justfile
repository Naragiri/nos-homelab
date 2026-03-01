#!/usr/bin/env -S just --justfile

_default:
  @just --list --unsorted

# Bootstraps a host using an ip address.
[group('ansible')]
[working-directory: 'ansible']
ansible-bootstrap HOST:
  ansible-playbook -b playbooks/bootstrap.yml -i "{{HOST}}," -e "target={{HOST}}"  -e "ansible_ssh_common_args='-o StrictHostKeyChecking=no'" --ask-pass --ask-become-pass

# Bootstraps a host from the inventory/hosts.yml.
[group('ansible')]
[working-directory: 'ansible']
ansible-bootstrap-inventory HOST:
  ansible-playbook -b playbooks/bootstrap.yml -e "target={{HOST}}" --ask-pass --ask-become-pass

# Runs the maintenance/update playbook on a given host.
[group('ansible')]
[working-directory: 'ansible']
ansible-update HOST:
  ansible-playbook -b playbooks/maintenance/update.yml --limit {{HOST}}

# Runs the main.yml playbook on a specified host.
[group('ansible')]
[working-directory: 'ansible']
ansible-run HOST *TAGS:
  ansible-playbook -b playbooks/main.yml --limit {{HOST}} {{TAGS}}

# Installs the dependencies from ansible-galaxy.
[group('ansible')]
[working-directory: 'ansible']
ansible-reqs:
  ansible-galaxy install -r requirements.yaml

[group('ansible-vault')]
[working-directory: 'ansible']
vault ACTION HOST:
  ansible-vault {{ACTION}} inventory/host_vars/{{HOST}}/vault.yml

[group('packer')]
[working-directory: 'packer']
packer-init DISTRO VERSION:
  packer init {{DISTRO}}/{{VERSION}}/

[group('packer')]
[working-directory: 'packer']
packer-build DISTRO VERSION:
  packer build -var-file={{DISTRO}}/{{VERSION}}/secrets.pkrvars.hcl {{DISTRO}}/{{VERSION}}/

[group('packer')]
[working-directory: 'packer']
packer-validate DISTRO VERSION:
  packer validate -var-file={{DISTRO}}/{{VERSION}}/secrets.pkrvars.hcl {{DISTRO}}/{{VERSION}}/
