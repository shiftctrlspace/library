# Shift-CTRL Space Library [![Build Status](https://travis-ci.org/shiftctrlspace/library.svg?branch=master)](https://travis-ci.org/shiftctrlspace/library)

The Shift-CTRL Space Library project is a self-hosted personal e-Book ([Calibre](https://calibre-ebook.com/)) library "in a box" designed to make it easy to securely share (primarily) texts among small- to medium-sized groups who are tightly resource-constrained. This means we are focused on supporting extremely low-cost, easily-available hardware. It's important to us that small groups or individuals without many resources have what they need to operate effectively despite having at best minimal support from existing economic or political systems.

That said, to set up your own Library, some initial resources are required. These include:

* An inexpensive computer, such as any model of [Raspberry Pi ("RPi")](https://www.raspberrypi.org/). You can purchase a new RPi for as little as $35 USD. Alternatively, you can often acquire a Raspberry Pi for free by simply asking around local programmer's meetups or other tech-focused watering holes; someone much richer than you has probably bought one of these "for a weekend project" that they never got around to actually doing. ;)
* An Internet connection, at least while setting up the Library initially. The cheapest plan from your local Internet Service Provider will almost certainly suffice. If you want to make your Library accessible to people who are not physically nearby (such as connected to the same Wi-Fi network as the Library hardware itself), you will also need to retain an Internet connection so that the Library can function as a remote server. Otherwise, you can simply set up the Library in a location where you have Internet access and then move it to some place you do not; the Library will continue to make its content available to the local area network to which it is connected.
* Some basic knowledge of command-line GNU/Linux system administration. If this is a new area for you, we highly recommend the NYC chapter of the Anarcho-Tech Collective's "[Foundations](https://github.com/AnarchoTechNYC/meta/wiki/Foundations)" series. In particular, we suggest starting at their "[Securing a Shell Account on a Shared Server](https://github.com/AnarchoTechNYC/meta/blob/master/train-the-trainers/practice-labs/securing-a-shell-account-on-a-shared-server/README.md)" guide if command-line interfaces are completely new to you.

To deploy and manage a Library, this project uses [Ansible playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html) that provision a simple Web server built into [Calibre](https://calibre-ebook.com/) (its [Content server](https://manual.calibre-ebook.com/generated/en/calibre-server.html)) to a given host or set of hosts.

Moreover, by default, the [`provision.yaml` playbook](playbooks/provision.yaml) will build a [Tor](https://torproject.org/) server from the Tor Project's GPG-signed source code, and expose the Calibre library as a stealth Onion service to a number of authenticated clients. This means people who want to access the Library from afar will need to use and configure their local Tor clients (such as [Tor Browser](https://www.torproject.org/download/download-easy.html)) with the appropriate access credentials ("library cards") before they are able to connect. Additionally, you can optionally enable "`onionshare_receiver_mode`" (based on [OnionShare](https://onionshare.org/)), which will create a second Onion service that allows anyone to anonymously upload new files in a sort of drop box for a Librarian to review in order to more organically grow the Library. Both of these features require a sustained Internet connection.

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

We intend a Library branch to be a computer that is not your personal computer. The Library branch hardware is, however, configured and managed from your personal computer. Therefore, to use these playbooks, you need the following software installed on your own computer:

* [Ansible](https://ansible.com/)
* [Calibre](https://calibre-ebook.com/)

We call the computer you choose to manage the Library from the *Ansible controller*. For the initial configuration, you'll also need the ability to [connect via SSH](https://github.com/AnarchoTechNYC/meta/blob/master/train-the-trainers/practice-labs/introduction-to-securing-virtualized-secure-shell-servers/README.md) to the Library branch computers (i.e., the machines you list in your [Ansible host inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)).

### Preparing the Ansible controller

1. [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
1. [Install Calibre](https://calibre-ebook.com/download).

Once Calibre is installed, you will need to create a Calibre Library. This Library is a folder, much like the iTunes Music folder, that is managed by Calibre. Use the Calibre interface to make any changes to the Library. Eventually, Ansible will be used to synchronize the Calibre Library folder on your Ansible controller over to the Library branch computers.

### Preparing the Library branch hardware

The Library branch computers must have sufficient storage space available to hold the contents of the library itself. (A future version of these playbooks may offer a way to use network-attached storage instead of directly-attached storage, like an SD card, to store the library content itself.) If your Library branch computers are Raspbery Pis, a suitable 128GB SD card currently retails for about $20 USD and will be able to comfortably house approximately 10,000 e-books, depending on the specific books, of course.

In the simplest case:

1. You can use [NOOBS](https://www.raspberrypi.org/documentation/installation/noobs.md) to install [Raspbian](https://www.raspbian.org/) onto a [Raspberry Pi](https://www.raspberrypi.org/).
1. Once the installation is complete, [use Raspbian's included `raspi-config` utility to enable the SSH service](https://www.raspberrypi.org/documentation/remote-access/ssh/), which will make it possible to remotely administer the Pi.
1. Connect the Raspberry Pi to a network, such as your home Wi-Fi network. (See [the Raspberry Pi documentation](https://www.raspberrypi.org/documentation/configuration/wireless/README.md) for some examples.)

If successful, you should now be able to access the Raspberry Pi's SSH service port for remote administration from your Ansible controller. You can test this with a command such as `nc -vz raspberry.local 22`, which will tell you that the connection "`succeeded`" if your Ansible controller can reach your Library branch. You will then be able to use this project's provided [`example/hosts` inventory file](inventories/example/hosts) to experiment with the playbooks unmodified.

### Installing requirements

After [installing the prerequisite software](#prerequisites), download this project's code. You can do so via command-line Git:

```sh
git clone https://github.com/shiftctrlspace/library.git
```

or using [this "Download" link](https://github.com/shiftctrlspace/library/archive/master.zip) from the Web site.

Next, you will need to retrieve this project's dependent Ansible roles (modules). Install them with `ansible-galaxy`:

```sh
cd library
ansible-galaxy install -r requirements.yaml
```

### Deploying a new library branch

The next step is to make a list of the Library branches (hosts) you'd like to manage. The files in [`inventories/example`](inventories/example) provide a start. You can copy this directory hierarchy to another folder (such as `inventories/production`) and modify the `hosts` file and any variables in the `group_vars/` folder therein to customize your deployment.

The example inventory file assumes a single, almost untouched Raspbian server. You can use it immediately like this:

```sh
ansible-playbook -i inventories/example/hosts --ask-pass playbooks/main.yaml
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

We recommend adding books to library branches by synchronizing them with a master copy of your content located on a workstation (such as your own laptop, the Ansible controller); to support multiple Librarians, a simplistic solution is to share the workstation itself or to place the Calibre Library folder on a shared fileserver. The provided example Ansible inventory expects to find this master Calibre Library on your Ansible controller in its `~/Documents/Calibre Library` folder. You can use plain old [rsync](https://rsync.samba.org/) to perform the synchronization from the Ansible controller to the Library branch, although you will find the included [`synchronize.yaml` playbook](playbooks/synchronize.yaml) easier to use. To synchronize the remote library branches with your local library copy:

```sh
ansible-playbook -i inventories/example/hosts playbooks/synchronize.yaml
```

Whenever you make a change to your local library from within the Calibre GUI, simply run the above `synchronize.yaml` playbook again. Adding a second Library branch is straightforward: prepare its hardware as above, and then add it to your Ansible inventory. Future synchronizations will sync *all* Library branches in parallel.

Occasionally, the Calibre Content server may not notice the new additions after a sync. This most often happens when a patron is actively browsing the Library while a synchronization process is updating the Calibre Library's `metadata.db` database file. Letting the Library remain idle for a little while (an hour?) will often be enough to refresh the books list, but you can optionally follow a synchronization by restarting the Calibre Content server's service like so to flush the old database out of memory and reload the updated one:

```sh
ansible -i inventories/example/hosts --become -m service -a "name=calibre@main.service state=restarted"
```

Future visits to the Library should now show the newly synchronized Library contents to all visitors.

#### Enabling OnionShare receiver mode

To allow uploads to your Library branch computer, you can enable "`onionshare_receiver_mode`" on one or more of your Library branch hosts. To keep things simple, we recommend that you enable this mode on only one of your Library branch computers. The [`inventories/example/host_vars/raspberry.local.yaml` file](inventories/example/host_vars/raspberry.local.yaml) provides an example configuration for the example inventory setup discussed in this README. It looks something like this:

```yaml
# Example host-specific inventory variable file for `raspberry.local`.
---
onionshare_receiver_mode: true
disk_quotas_users:
    - name: "{{ onionshare_username }}"
      block_hard: 5G
```

The important line is `onionshare_receiver_mode: true`, which will enable provisioning of the OnionShare server in receive mode. The second item, the `disk_quotas_users` list, defines the disk space usage limit for the Operating System user account under which the OnionShare server runs. This prevents files that anonymous users upload from using more than the permitted amount of space on the Library branch filesystem. It is set to 5 gibibytes by default, but you can [adjust this](https://github.com/AnarchoTechNYC/ansible-role-common/blob/master/README.md#configuring-disk-quotas) if you wish.

Once deployed, you can find the Onion service's address in the [systemd journal](https://www.freedesktop.org/software/systemd/man/systemd-journald.service.html) for your Library branch's `onionshare.service` unit:

```sh
# Using an Ansible ad-hoc command:
ansible raspberry.local -i inventories/example/hosts --ask-pass -m "shell" -a "journalctl --unit onionshare.service | grep -A 1 'Give this address to the sender'"

# Or using plain old SSH:
ssh pi@raspberry.local journalctl --unit onionshare.service | grep -A 1 'Give this address to the sender'
```

Of course, allowing anonymous users to upload files to your Library branch computer means that an attacker could upload a malicious file such as malware or a virus that will take over the computer that opens the file, so please [take precautions and educate yourself about the risks and mitigations available to you](#keeping-your-library-free-of-viruses-and-malware) before accepting files from others.

### Keeping your Library free of viruses and malware

An ounce of prevention is worth a pound of cure. In other words, try to avoid adding files to your Library that contain viruses or malware in the first place. The best way to do this is to receive files from trusted sources and to closely inspect each file you intend to add to your Library before you add it. You can inspect files manually, or using any number of anti-virus tools and scanners.

Alternatively, you can use the provided `scan-library.sh` utility. It is a small [Bash shell](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) script that finds all significant files within a Calibre Library folder and scans them against more than sixty anti-virus scanners by uploading the file to the [VirusTotal](https://virustotal.com/) Web site, which provides a public [API](https://www.virustotal.com/en/documentation/public-api/). Note that this will provide VirusTotal with a copy of your library contents, so *do not* use this method if you have included sensitive or private texts in your Library. To use this script, you will need to install the free [VirusTotal command-line tool, `vt`](https://github.com/VirusTotal/vt-cli/blob/master/README.md#installing-the-tool). Once installed, use `bin/scan-library.sh --help` for usage information.

## Developing

> :construction: TK-TODO: Some advice on how to set up a local development environment for this playbook given the above preamble.
