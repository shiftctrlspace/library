# Shift-CTRL Space Library

The Shift-CTRL Space Library project is an automated, self-hostable personal e-Book library "in a box." This repository contains provisioning scripts ([Ansible playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html)) that will deploy a simple [Calibre](https://calibre-ebook.com/) Library server to a given host (or set of hosts). Unless you specify otherwise, the playbooks are written to optimize hosts by removing software often found on most systems, including graphical shells, in order to maximize the amount of available disk and memory space that can be used by the library.

> :warning: It bears repeating: **by default, this project will remove (uninstall) graphical desktop environments as well as other software designed to make most operating systems usable by people who are unfamiliar with command-line system administration.** Please do not use these playbooks unless you are ready to administer a "headless" (command-line only) server.

We call a given host that is running the Calibre content server software with directly-attached storage containing a Calibre Library a *library branch*. Following the same metaphor, we call the people responsible for adding, removing, and cataloguing the contents of the library *librarians*. In the simplest case, with a single host and a single librarian, that librarian is also the de-facto system administrator of that library branch's hardware and software.

## Prerequisites

To use these playbooks, you need the following software installed on your own computer:

* [Ansible](https://ansible.com/)

You'll also need the ability to connect via SSH to the machines you list in your [host inventory](hosts.example). Also, of course, those hosts must have sufficient storage space available to hold the contents of the library. (A future version of these playbooks may offer a way to use NAS instead of DAS to store the library content itself.)

In the simplest case, you can use [NOOBS](https://www.raspberrypi.org/downloads/noobs/) to install [Raspbian](https://www.raspbian.org/) onto a [Raspberry Pi](https://www.raspberrypi.org/). Once the installation is complete, [use Raspbian's included `raspi-config` utility to enable the SSH service](https://www.raspberrypi.org/documentation/remote-access/ssh/), which will make it possible to remotely administer the Pi.

## Deploying

Once you are able to remotely administer your host(s) over SSH and have installed a recent-enough version of Ansible (we test with Ansible 2.6.5 and later), you can deploy the Library with the following command that assumes an almost-untouched Raspbian server:

```sh
ansible-playbook -i hosts.example -u pi --ask-pass calibre-server.yml
```

Depending on the speed of your Internet connection and your hardware, the deployment could take quite a bit of time. Moreover, **your graphical shell will be uninstalled to save space** so if you have installed NOOBS or any other desktop environment, be prepared for your screen to black out and to be dropped into a console. If you do not want to uninstall any software, pass `-e uninstall_unnecessary_packages=false` to the deployment command, above.

## Adding, removing, and editing the metadata of books

Once provisioned, each host will have a system user with which you can manage your library. The [`calibre` role](roles/calibre/) will generate an Ed25519 SSH key for doing so. This key will be placed in your user's `~/.ssh/ansible-controller/` directory on the Ansible controller. You can then use this key to log in to the Calibre server's host machine with a command such as:

```sh
ssh -i ~/.ssh/ansible-controller/"$HOST"/"$CALIBRE_HOME"/.ssh/"$CALIBRE_USER"_librarian_ed25519 calibre@"$HOST"
```

We recommend adding books to the library by synchronizing a second copy of your content on a workstation (such as your laptop) using `rsync(1)`.

> :construction: TK-TODO: Finish describing how to add Library content.
> :construction: TK-TODO: Write instructions for dealing with content.
