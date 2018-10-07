# Tor role

This directory contains an Ansible role for building a Tor server on a Debian 9 ("Jessie") based Operating System from source. Notably, it has been tested with Raspbian. Its purpose is to make it simple to install a Tor server that can be used as an Onion service server.

# Default variables

This role provides [default variables](defaults/main.yml), which you can override using any of [Ansible's variable precedence rules](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable). Notable default variables you may wish to override to customize your Calibre configuration are listed here:

* `tor_package_build_dir`: The temporary directory in which to checkout the Tor project's source code.
* `tor_data_dir`: The Tor server's data directory.
* `tor_onion_services_dir`: The directory in which to place Onion service private keys.
