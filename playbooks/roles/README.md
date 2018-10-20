# Library roles

This directory exists in order to make it simple to add new roles to the Library project. The [required roles](../requirements.yml) can be installed into this directory by invoking `ansible-galaxy` with the `--roles-path` option. For example, from the project root:

```sh
ansible-galaxy install -r requirements.yml --roles-path roles/
```

Omitting `--roles-path` will place the required roles in whatever directory your Ansible is configured to use (`/etc/ansible/roles` by default).

If you cloned the project repository directly using Git, you can also add roles here by adding them as submodules. For example, to add a follow-on role called "`moar-books`" hosted on your own Git server:

```sh
git submodule add git@your.server.com:moar-books.git moar-books
```
