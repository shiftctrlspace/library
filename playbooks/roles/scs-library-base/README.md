# Shift-CTRL Space Library: Base

This role prepares a managed node for service as a Library branch. 

## Role variables

* `hardened_hosts`: Boolean indicating whether or not to run baseline hardening tasks.
* `sshd_allow_group`: If `hardened_hosts` is set and this is set, determines the Operating System user account to restrict SSH access. For example:
    ```yml
    hardened_hosts: true        # Perform system hardening.
    sshd_allow_group: ssh-users # Limit SSH access to users in the `ssh-users` group.
    ```
    If `hardened_hosts` is `true` but `sshd_allow_group` is undefined, system hardening will proceed but the procedure will not restrict SSH access by user group.
