# Library tasks

This directory contains [Ansible tasks](https://docs.ansible.com/ansible/latest/network/getting_started/basic_concepts.html#tasks) that are (more or less) unique to this project. They come in two main groupings:

* Common tasks.

  Common tasks are contained in the files whose names start with `common` and are preparatory chores performed to prepare a host for its role as a Library branch.

* Hardening tasks.

  Hardening tasks are contained in the files whose names start with `harden` and are security-focused operations intended to limit the attack surface of a given host. These tasks can be skipped by setting the playbook's `hardened_hosts` variable to `false`, e.g., `ansible-playbook -e hardened_hosts=false […]`.
