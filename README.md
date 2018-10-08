# Shift-CTRL Space Library

The Shift-CTRL Space Library project is an automated, self-hostable personal e-Book library "in a box" accessible over the Dark Web. This repository contains provisioning scripts ([Ansible playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html)) that will deploy a simple [Calibre](https://calibre-ebook.com/) Library server to a given host (or set of hosts) and, by default, expose that library as a stealth Tor Onion service to authenticated clients (i.e., people with "library cards"). Unless you specify otherwise, the playbooks are written to optimize hosts by removing software often found on most systems, including graphical shells, in order to maximize the amount of available disk and memory space that can be used by the library.

> :warning: It bears repeating: **by default, this project will remove (uninstall) graphical desktop environments as well as other software designed to make most operating systems usable by people who are unfamiliar with command-line system administration.** Please do not use these playbooks unless you are ready to administer a "headless" (command-line only) server.

We call a given host that is running the Calibre content server software with directly-attached storage containing a Calibre Library a *library branch*. Following the same metaphor, we call the people responsible for adding, removing, and cataloguing the contents of the library *librarians*. In the simplest case, with a single host and a single librarian, that librarian is also the de-facto system administrator of that library branch's hardware and software.

## Prerequisites

To use these playbooks, you need the following software installed on your own computer:

* [Ansible](https://ansible.com/)

You'll also need the ability to connect via SSH to the machines you list in your [host inventory](hosts.example). Also, of course, those hosts must have sufficient storage space available to hold the contents of the library. (A future version of these playbooks may offer a way to use NAS instead of DAS to store the library content itself.)

In the simplest case, you can use [NOOBS](https://www.raspberrypi.org/downloads/noobs/) to install [Raspbian](https://www.raspbian.org/) onto a [Raspberry Pi](https://www.raspberrypi.org/). Once the installation is complete, [use Raspbian's included `raspi-config` utility to enable the SSH service](https://www.raspberrypi.org/documentation/remote-access/ssh/), which will make it possible to remotely administer the Pi.

## Downloading

Some components are included as [Git submodules](https://git-scm.com/book/en/Git-Tools-Submodules), so use [`git clone --recursive`](http://explainshell.com/explain?cmd=git+clone+--recursive) to download all the dependent roles:

```sh
git clone --recursive https://github.com/shiftctrlspace/library.git
```

## Deploying

Once you are able to remotely administer your host(s) over SSH and have installed a recent-enough version of Ansible (we test with Ansible 2.6.5 and later), the next step is to make a list of the library branches (hosts) you'd like to manage. The [`hosts.example`](hosts.example) provides a start. Copy this file and list the IP addresses or domain names of your library nodes there.

Then you can run the playbook against each library branch node:

```sh
cp hosts.example hosts                       # Copy the example inventory to get started.
vim hosts                                    # Edit the inventory file to list your library branches.
ansible-playbook -i hosts calibre-server.yml # Run the playbook against your inventory file.
```

The example inventory file assumes an almost untouched Raspbian server. You can use it immediately like this:

```sh
ansible-playbook -i hosts.example -u pi --ask-pass calibre-server.yml
```

Depending on the speed of your Internet connection and your hardware, the deployment could take quite a bit of time. Moreover, **your graphical shell will be uninstalled to save space** so if you have installed NOOBS or any other desktop environment, be prepared for your screen to black out and to be dropped into a console. If you do not want to uninstall any software, pass `-e uninstall_unnecessary_packages=false` to the deployment command, above.

By default, a successful deployment will expose the (empty) Calibre Library as an authenticated stealth Onion service. You can retrieve the Onion service authentication credentials to a given Library branch (`raspberry.local`) for a given client (`alice`) and then [distribute these credentials to friends, family, or comrades](https://github.com/AnarchoTechNYC/meta/wiki/Connecting-to-an-authenticated-Onion-service):

```sh
# Using Ansible:
ansible raspberry.local -i hosts -u pi --ask-pass --become -a "grep 'alice$' /var/lib/tor/onion-services/onion-library/hostname"

# Using plain old SSH:
ssh pi@raspberry.local "sudo grep 'alice$' /var/lib/tor/onion-services/onion-library/hostname"
```

Continuing the library metaphor, we call these stealth Onion authentication credentials *library cards*.

## Adding, removing, and editing the metadata of books

Once provisioned, each host will have a system user with which you can manage your library. The [`calibre` role](roles/calibre/) will generate an Ed25519 SSH key for doing so. This key will be placed in your user's `~/.ssh/` directory on the Ansible controller. You can then use this key to log in to the Calibre server's host machine with a command such as:

```sh
ssh -i ~/.ssh/"$HOST"/"$CALIBRE_HOME"/.ssh/"$CALIBRE_USER"_librarian_ed25519 "$CALIBRE_USER"@"$HOST"
```

We recommend adding books to the library by synchronizing a second copy of your content on a workstation (such as your laptop) using `rsync(1)`. For example:

```sh
rsync -zrvthP --delete -e "ssh -i ~/.ssh/${HOST}/${CALIBRE_HOME}/.ssh/${CALIBRE_USER}_librarian_ed25519" /path/to/local/library/ "$CALIBRE_USER"@"$HOST":"$CALIBRE_LIBRARY_DIR"
```

> :construction: TODO: Write a separate playbook for handling content so that Library management can be performed using Ansible, as well.
>
> :construction: TK-TODO: Finish describing how to add Library content.
