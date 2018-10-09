# Shift-CTRL Space Library

The Shift-CTRL Space Library project is a self-hosted personal e-Book ([Calibre](https://calibre-ebook.com/)) library "in a box" designed to make it easy to securely share (primarily) texts among small- to medium-sized groups who are tightly resource-constrained. This means we are focused on supporting extremely low-cost, easily-available hardware. It's important to us that small groups or individuals without many resources have what they need to operate effectively despite having at best minimal support from existing economic or political systems.

That said, to set up your own Library, some initial resources are required. These include:

* An inexpensive computer, such as any model of [Raspberry Pi ("RPi")](https://www.raspberrypi.org/). You can purchase a new RPi for as little as $35 USD. Alternatively, you can often acquire a Raspberry Pi for free by simply asking around local programmer's meetups or other tech-focused watering holes; someone much richer than you has probably bought one of these "for a weekend project" that they never got around to actually doing. ;)
* An Internet connection, at least while setting up the Library initially. The cheapest plan from your local Internet Service Provider will almost certainly suffice. If you want to make your Library accessible to people who are not physically nearby (such as connected to the same Wi-Fi network as the Library hardware itself), you will also need to retain an Internet connection so that the Library can function as a remote server. Otherwise, you can simply set up the Library in a location where you have Internet access and then move it to some place you do not; the Library will continue to make its content available to the local area network to which it is connected.
* Some basic knowledge of command-line GNU/Linux system administration. If this is a new area for you, we highly recommend the NYC chapter of the Anarcho-Tech Collective's "[Foundations](https://github.com/AnarchoTechNYC/meta/wiki/Foundations)" series. In particular, we suggest starting at their "[Securing a Shell Account on a Shared Server](https://github.com/AnarchoTechNYC/meta/blob/master/train-the-trainers/practice-labs/securing-a-shell-account-on-a-shared-server/README.md)" guide if command-line interfaces are completely new to you.

Unless you specify otherwise, the playbooks are written to optimize hosts by removing software often found on most systems, including graphical shells, in order to maximize the amount of available disk and memory space that can be used by the library.

> :warning: It bears repeating: **by default, this project will remove (uninstall) graphical desktop environments as well as other software designed to make most operating systems usable by people who are unfamiliar with command-line system administration.** Please do not use these playbooks unless you are ready to administer a "headless" (command-line only) server.

Once again, we encourage you to acquire the skills you need to manage this Library from the [Anarcho-Tech Collective](https://github.com/AnarchoTechNYC/meta/wiki)'s great guides and [practice labs](https://github.com/AnarchoTechNYC/meta/tree/master/train-the-trainers/practice-labs/). It won't take as long as you might fear, and what you learn will be useful for the rest of your life. Promise.

## Contents

1. [Libraries, Librarians, and Library cards](#libraries-librarians-and-library-cards)
1. [Set up a new Library](#set-up-a-new-library)
    1. [Prerequisites](#prerequisites)
    1. [Downloading the project code](#downloading-the-project-code)
    1. [Deploying a new Library branch](#deploying-a-new-library-branch)
    1. [Adding, removing, and editing the metadata of books](#adding-removing-and-editing-the-metadata-of-books)
1. [Developing](#developing)

## Libraries, Librarians, and Library cards

In order to simplify understanding this project and to make it easier to communicate with others who use this project, we use the metaphor of a physical community library.

* The folder that contains the e-books and other content available for browsing, sharing, and reading is called a *library*.
* The machine on which a library (folder) exists that is running the Calibre content server software is called a *library branch*.
* The people responsible for adding, removing, and cataloguing the contents of the library are called *librarians*. A library branch must have at least one librarian, although any number of librarians can share responsibility for a single library branch.
* People who have been pre-approved by a librarian to access the library's content even while they are not physically near the library itself are given a set of access credentials that we call *library cards*. These are optional; by default, no remote access is permitted without a library card.

To deploy and manage a Library, this project uses [Ansible playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html) that provisions a simple [Calibre](https://calibre-ebook.com/) Web server to a given host (or set of hosts). Moreover, by default, the provisioning scripts will build a [Tor](https://torproject.org/) server from the Tor Project's GPG-signed source code, and expose the Calibre library as a stealth Onion service to a list of authenticated clients. This means people who want to access the Library from afar will need to use and configure their local Tor clients (such as [Tor Browser](https://www.torproject.org/download/download-easy.html)) with the appropriate access credentials ("library cards")  before they are able to connect.

## Set up a new Library

This section describes the process of setting up a new Library branch in the default configuration.

### Prerequisites

To use these playbooks, you need the following software installed on your own computer:

* [Ansible](https://ansible.com/)

You'll also need the ability to connect via SSH to the machines you list in your [host inventory](hosts.example). Also, of course, those hosts must have sufficient storage space available to hold the contents of the library. (A future version of these playbooks may offer a way to use NAS instead of DAS to store the library content itself.)

In the simplest case, you can use [NOOBS](https://www.raspberrypi.org/downloads/noobs/) to install [Raspbian](https://www.raspbian.org/) onto a [Raspberry Pi](https://www.raspberrypi.org/). Once the installation is complete, [use Raspbian's included `raspi-config` utility to enable the SSH service](https://www.raspberrypi.org/documentation/remote-access/ssh/), which will make it possible to remotely administer the Pi.

### Downloading the project code

> :construction: TK-TODO: Fill this out a bit more. We should consider also using Ansible requirements instead of Git submodules directly so that people only ever have to install Ansible.

Some components are included as [Git submodules](https://git-scm.com/book/en/Git-Tools-Submodules), so use [`git clone --recursive`](http://explainshell.com/explain?cmd=git+clone+--recursive) to download all the dependent roles:

```sh
git clone --recursive https://github.com/shiftctrlspace/library.git
```

### Deploying a new library branch

Once you are able to remotely administer your host(s) over SSH and have installed a recent-enough version of Ansible (we test with Ansible 2.6.5 and later), the next step is to make a list of the library branches (hosts) you'd like to manage. The [`hosts.example`](hosts.example) provides a start. Copy this file and list the IP addresses or domain names of your library nodes there.

Then you can run the playbook against each library branch node:

```sh
cp hosts.example inventories/prod # Copy the example inventory to get started.
vim inventories/prod              # Edit the inventory file to list your library branches.

# Run the playbook against your production inventory.
ansible-playbook -i inventories/prod provision.yml
```

The example inventory file assumes an almost untouched Raspbian server. You can use it immediately like this:

```sh
ansible-playbook -i hosts.example --ask-pass provision.yml
```

Depending on the speed of your Internet connection and your hardware, the deployment could take quite a bit of time. Moreover, **your graphical shell will be uninstalled to save space** so if you have installed NOOBS or any other desktop environment, be prepared for your screen to black out and to be dropped into a console. If you do not want to uninstall any software, pass `-e uninstall_unnecessary_packages=false` to the deployment command, above.

By default, a successful deployment will expose the (empty) Calibre Library as an authenticated stealth Onion service. You can retrieve the Onion service authentication credentials to a given Library branch (`raspberry.local`) for a given client (`alice`) and then [distribute these credentials to friends, family, or comrades](https://github.com/AnarchoTechNYC/meta/wiki/Connecting-to-an-authenticated-Onion-service):

```sh
# Using Ansible:
ansible raspberry.local -i hosts.example --ask-pass --become -a "grep 'alice$' /var/lib/tor/onion-services/onion-library/hostname"

# Using plain old SSH:
ssh pi@raspberry.local "sudo grep 'alice$' /var/lib/tor/onion-services/onion-library/hostname"
```

Continuing the library metaphor, we call these stealth Onion authentication credentials *library cards*.

### Adding, removing, and editing the metadata of books

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

## Developing


> :construction: TK-TODO: Some advice on how to set up a local development environment for this playbook given the above preamble.
