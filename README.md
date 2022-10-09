# RHINO Ansible Playbooks for Validator Operations

This repository is a fork of two great upstream projects that formed 90% of the basis of this work:

- Polkachu's [Cosmos Validators](https://github.com/polkachu/cosmos-validators) repo, and
- LavenderFive's [Secure Server Setup](https://github.com/LavenderFive/secure-server-setup-ansible) repo (which is a fork from Polkachu)

Basically, all things lead back to Polkachu automation. One final note, constant reader, is that these playbooks are offered to you as inspiration, not implementation.

## What's different in this repo

Although mostly the same, our philosophy and use of hardware is slightly different than the sources of this fork. RHINO utilizes a combination of RHINO owned Enterprise hardware that sit in 2 North America based colos and cloud based servers positioned globally.

This requires a mix of both vSphere and bare metal orchestration, including servers located by RHINO, Hetzner, OVH, Interserver or others.

There are a few other notes of this repo:

- Combined both server setup and "node" setup in a single repo
- Extra playbooks to bootstrap vSphere template files (including multi-nic nodes)
- Handle sudo enabled and non-sudo enabled servers
- Additional tweaks based on our experience and needs

## How to use this repository

Copy inventory file

```bash
cp inventory.sample inventory.ini
```

Update information in the inventory file. Mostly like you will need to update the server IP and hostname fields, create groups, all that. Then run main ansible playbook.

```bash
# For init'ing new machines, two playbooks exist:
#
# vSphere machines that carry multiple IPs:
ansible-playbook main_init_vsphere --limit groupName
# These inventory items carry additional fields: internal_ip="10.254.106.175" external_ip="38.146.3.175"
#
# Bare metal from cloud providers.  These are typically provisioned with a username (debian, etc.) using a provided security key.
ansible-playbook main_init_bare --limit groupName
# These inventory items carry an additional field for the initial login: initial_user="debian".  This user is deleted at the end of this profile.

# For Basic user and security setup:
ansible-playbook main.yaml --limit groupName

# For Cosmos init:
ansible-playbook main_cosmos_node.yml --limit groupName # or machineName

# To stage an upgrade
# upgrade_name is the upgrade name as defined in the proposal.  node_version overrides the variable as set in the vars file.
# Caution: This will replace the version located in $HOME/go/bin with this upgraded version, so be sure to not run this manually prior to upgrade or you could app-hash and have to re-sync

ansible-playbook main_cosmos_node_upgrade.yml --limit groupName -e "upgrade_name=v1.2.0beta node_version=v1.2.0beta"


```

`main_setup` and `main_secure` scripts are responsible for setting up a machine that already has a reasonable IP set. `main_init` helps provision from RHINO created templates from a colo managed environment. `*_node` playbooks are based on our experience and management of nodes at scale.

## High-Level Playbooks

### main_setup

1. We use a single user for ansible & job management, following the K.I.S.S. principle.
2. Configure Machine: Update packages, set the hostname (based on inventory file), hosts file, user limits
3. Install essential software, set machines to UTC, set appropriate `tuned` profile
4. Add aliases for Cosmos job management

### main_secure

1. ufw & subnet rules appropriate for RHINO use
2. Disable root account access & password authentication.

## Warning

By default, these `ufw` rules disable _all_ inbound access other than from specific subnets. Running this blind will lock you out of a cloud based machine.

## Node Playbooks

"Node" in this case means a blockchain node that is playing a role. For RHINO, we view these nodes as "100% disposable", simply processing information for the purposes of the signing cluster that will sign blocks.

From the configuration proposed for Cosmos nodes, for example, you will see heavily pruned nodes that will install the latest chain binary and be prepped to state-sync.

Any questions, reach out to us. Contact information is available on our website, [https://rhinostake.com](https://rhinostake.com).
