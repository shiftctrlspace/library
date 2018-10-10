# Calibre role

This directory contains an Ansible role for configuring the Calibre content server (`calibre-server`) on a Debian 9 ("Jessie") based Operating System. Notably, it has been tested with Raspbian. Its purpose is to make it simple to install a local server that provides access to a given Calibre Library.

# Default variables

This role provides [default variables](defaults/main.yml), which you can override using any of [Ansible's variable precedence rules](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable). Notable default variables you may wish to override to customize your Calibre configuration are listed here:

* `calibre_server_username`: The system user name under which the Calibre server will run.
* `calibre_server_home_dir`: The home directory of the Calibre server's user account.
* `calibre_server_user_groups`: List of additional user groups to add the Calibre server user account to.
* `calibre_server_library_dir`: The name of the directory in which to place the Calibre Library. I.e., Calibre's `metadata.db` file will be created here.
* `calibre_server_listen_port`: The TCP port number to which the Calibre server should bind to.
