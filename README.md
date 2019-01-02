# Shift-CTRL Space Library [![Build Status](https://travis-ci.org/shiftctrlspace/library.svg?branch=master)](https://travis-ci.org/shiftctrlspace/library)

The Shift-CTRL Space Library project is a self-hosted personal e-Book ([Calibre](https://calibre-ebook.com/)) library "in a box" designed to make it easy to securely share (primarily) texts among small- to medium-sized groups who are tightly resource-constrained. This means we are focused on supporting extremely low-cost, easily-available hardware. It's important to us that small groups or individuals without many resources have what they need to operate effectively despite having at best minimal support from existing economic or political systems.

That said, to set up your own Library, some initial resources are required. These include:

* An inexpensive computer, such as any model of [Raspberry Pi ("RPi")](https://www.raspberrypi.org/). You can purchase a new RPi for as little as $35 USD. Alternatively, you can often acquire a Raspberry Pi for free by simply asking around local programmer's meetups or other tech-focused watering holes; someone much richer than you has probably bought one of these "for a weekend project" that they never got around to actually doing. ;)
* An Internet connection, at least while setting up the Library initially. The cheapest plan from your local Internet Service Provider will almost certainly suffice. If you want to make your Library accessible to people who are not physically nearby (such as connected to the same Wi-Fi network as the Library hardware itself), you will also need to retain an Internet connection so that the Library can function as a remote server. Otherwise, you can simply set up the Library in a location where you have Internet access and then move it to some place you do not; the Library will continue to make its content available to the local area network to which it is connected.
* Some basic knowledge of command-line GNU/Linux system administration. If this is a new area for you, we highly recommend the NYC chapter of the Anarcho-Tech Collective's "[Foundations](https://github.com/AnarchoTechNYC/meta/wiki/Foundations)" series. In particular, we suggest starting at their "[Securing a Shell Account on a Shared Server](https://github.com/AnarchoTechNYC/meta/blob/master/train-the-trainers/practice-labs/securing-a-shell-account-on-a-shared-server/README.md)" guide if command-line interfaces are completely new to you.

To deploy and manage a Library, this project uses [Ansible playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html) that provision a simple Web server built into [Calibre](https://calibre-ebook.com/) (its [Content server](https://manual.calibre-ebook.com/generated/en/calibre-server.html)) to a given host or set of hosts. Moreover, by default, the [`provision.yml` playbook](playbooks/provision.yml) will build a [Tor](https://torproject.org/) server from the Tor Project's GPG-signed source code, and expose the Calibre library as a stealth Onion service to a number of authenticated clients. This means people who want to access the Library from afar will need to use and configure their local Tor clients (such as [Tor Browser](https://www.torproject.org/download/download-easy.html)) with the appropriate access credentials ("library cards") before they are able to connect.

Once again, we encourage you to acquire the skills you need to manage this Library from the [Anarcho-Tech Collective](https://github.com/AnarchoTechNYC/meta/wiki)'s great guides and [practice labs](https://github.com/AnarchoTechNYC/meta/tree/master/train-the-trainers/practice-labs/). It won't take as long as you might fear, and what you learn will be useful for the rest of your life. Promise.

## Contents

1. [Libraries, Librarians, and Library cards](#libraries-librarians-and-library-cards)
1. [Set up a new Library](#set-up-a-new-library)
    1. [Prerequisites](#prerequisites)
    1. [Downloading the project code](#downloading-the-project-code)
    1. [Deploying a new Library branch](#deploying-a-new-library-branch)
    1. [Adding, removing, and editing the metadata of books](#adding-removing-and-editing-the-metadata-of-books)
    1. [Keeping your Library free of viruses and malware](#keeping-your-library-free-of-viruses-and-malware)
1. [Developing](#developing)

## Libraries, Librarians, and Library cards

In order to simplify understanding this project and to make it easier to communicate with others who use this project, we use the metaphor of a physical community library.

* The folder that contains the e-books and other content available for browsing, sharing, and reading is called a *library*.
* The machine on which a library (folder) exists that is running the Calibre content server software is called a *library branch*.
* The people responsible for adding, removing, and cataloguing the contents of the library are called *librarians*. A library branch must have at least one librarian, although any number of librarians can share responsibility for a single library branch.
* People who have been pre-approved by a librarian to access the library's content even while they are not physically near the library itself are given a set of access credentials that we call *library cards*. These are optional; by default, no remote access is permitted without a library card.

## Set up a new Library

This section describes the process of setting up a new Library branch in the default configuration.

### Prerequisites

To use these playbooks, you need the following software installed on your own computer:

* [Ansible](https://ansible.com/)

You'll also need the ability to connect via SSH to the machines you list in your [host inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html). Also, of course, those hosts must have sufficient storage space available to hold the contents of the library. (A future version of these playbooks may offer a way to use NAS instead of DAS to store the library content itself.)

In the simplest case, you can use [NOOBS](https://www.raspberrypi.org/documentation/installation/noobs.md) to install [Raspbian](https://www.raspbian.org/) onto a [Raspberry Pi](https://www.raspberrypi.org/). Once the installation is complete, [use Raspbian's included `raspi-config` utility to enable the SSH service](https://www.raspberrypi.org/documentation/remote-access/ssh/), which will make it possible to remotely administer the Pi. You will then be able to use this project's provided [`example/hosts` inventory file](inventories/example/hosts) to experiment with the playbooks unmodified.

### Installing requirements

After you have downloaded this project's code, you will need to retrieve its dependencies. Install them with `ansible-galaxy`:

```sh
ansible-galaxy install -r requirements.yml
```

Or, if you prefer to keep the project's dependent roles inside the project folder:

```sh
ansible-galaxy install --roles-path roles/ -r requirements.yml
```

### Deploying a new library branch

Once you are able to remotely administer your host(s) over SSH and have installed a recent-enough version of Ansible, the next step is to make a list of the library branches (hosts) you'd like to manage. The files in [`inventories/example`](inventories/example) provide a start. You can copy this directory hierarchy to another folder (such as `inventories/production`) and modify the `hosts` file and any variables in the `group_vars/` folder therein to customize your deployment.

The example inventory file assumes a single, almost untouched Raspbian server. You can use it immediately like this:

```sh
ansible-playbook -i inventories/example/hosts --ask-pass playbooks/main.yml
```

> :beginner: The default administrative user on a Raspbian system is `pi`, and its  password is `raspberry`. At a minimum, you should change this password on any production systems. We recommend changing the username as well.

Depending on the speed of your Internet connection and your hardware, the deployment could take quite a bit of time. By default, a successful deployment will expose the (empty) Calibre Library as an authenticated stealth Onion service. You can retrieve the Onion service authentication credentials to a given Library branch (such as `raspberry.local`) for a given client (such as `alice`) like this:

```sh
# Using Ansible:
ansible raspberry.local -i inventories/example/hosts --ask-pass --become -a "grep 'alice$' /var/lib/tor/onion-services/onion-library/hostname"

# Using plain old SSH:
ssh pi@raspberry.local "sudo grep 'alice$' /var/lib/tor/onion-services/onion-library/hostname"
```

Once you have the Onion service authentication cookie for some user (their "library card"), you should securely share it with them so that they may [configure their local Tor](https://github.com/AnarchoTechNYC/meta/wiki/Connecting-to-an-authenticated-Onion-service) to access your Library branch.

### Adding, removing, and editing the metadata of books

Once provisioned, each host will have a system user with which you can manage your library. The required [`calibre` role](https://github.com/shiftctrlspace/ansible-role-calibre/#readme) will generate an Ed25519 SSH key for doing so. This key will be placed in your user's `$HOME/.ssh/` directory on the Ansible controller. You can then use this key to log in to the Calibre server's host machine with a command such as:

```sh
ssh -i ~/.ssh/raspberry.local/srv/calibre/.ssh/calibre_librarian_ed25519 calibre@raspberry.local
```

We recommend adding books to library branches by synchronizing them with a master copy of your content located on a workstation (such as your laptop). The example inventory expects to find this library on your Ansible controller in the `~/Documents/Calibre Library` folder. You can use plain old [rsync](https://rsync.samba.org/) to perform the synchronization, although you will find the included [`synchronize.yml` playbook](playbooks/synchronize.yml) easier to use. To synchronize the remote library branches with your local library copy:

```sh
ansible-playbook -i inventories/example/hosts playbooks/synchronize.yml
```

Whenever you make a change to your local library from within the Calibre GUI, simply run the above `synchronize.yml` playbook again. Occasionally, the Calibre Content server may not notice the new additions, so you can optionally follow up by restarting the service:

```sh
ansible -i inventories/example/hosts --become -m service -a "name=calibre@main.service state=restarted"
```

### Keeping your Library free of viruses and malware

An ounce of prevention is worth a pound of cure. In other words, try to avoid adding files to your Library that contain viruses or malware in the first place. The best way to do this is to receive files from trusted sources and to closely inspect each file you intend to add to your Library before you add it. You can inspect files manually, or using any number of anti-virus tools and scanners.

Alternatively, you can use the provided `scan-library.sh` utility. It is a small [Bash shell](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) script that finds all significant files within a Calibre Library folder and scans them against more than sixty anti-virus scanners using the [VirusTotal](https://virustotal.com/) public [API](https://www.virustotal.com/en/documentation/public-api/). To use this script, you will need to install the free [VirusTotal command-line tool, `vt`](https://github.com/VirusTotal/vt-cli/blob/master/README.md#installing-the-tool). Once installed, use `bin/scan-library.sh --help` for usage information.

## Developing

> :construction: TK-TODO: Some advice on how to set up a local development environment for this playbook given the above preamble.
