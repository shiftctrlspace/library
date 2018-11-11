# Library roles

This directory contains project-specific [Ansible roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html), that is, roles that are not maintained separately as their own project (and thus generic enough to warrant inclusion through [`requirements.yml`](../../requirements.yml) file instead of directly placing them into this folder). Those roles can be installed into this directory by invoking `ansible-galaxy` with the `--roles-path` option. For example, from the project root:

```sh
ansible-galaxy install -r requirements.yml --roles-path roles/
```

Omitting `--roles-path` will place the required roles in whatever directory your Ansible is configured to use (`/etc/ansible/roles` by default).

Another way to add roles to this project, if you cloned the project repository directly using Git, you can add roles here by adding them as submodules. For example, to add a follow-on role called "`moar-books`" hosted on your own Git server:

```sh
git submodule add git@your.server.com:moar-books.git moar-books
```

In order to help assure a unique name, each project-specific role begins with the `scs-libray-` prefix. For example, the [`scs-library-base`](scs-library-base/) directory contains the `scs-library-base` role.
