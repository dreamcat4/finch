# FreeBSD in a chroot

<!-- <mark>highlighted</mark> -->
<!-- _This is an underlined sentence_.  and a ~~strikethrough definition~~  -->

<!-- *Putting the FreeBSD back into* ***[FreeNAS][fn]*** *and* ***[NAS4Free][n4f]***. -->
*For* ***[FreeNAS][fn]***, ***[NAS4Free][n4f]*** *and* ***[pfSense][pf]***.

[[ toc ]]

[fu]:usage
[fup]:upgrading
[faq]:faq
[jht]:jails-how-to
[fbh]:install/#toc_1
[presteps]:install/#toc_2
[poststeps]:install/#toc_12
[fm]:manpage
[pr]:#toc_3
[ch]:http://www.freebsd.org/cgi/man.cgi?query=chroot
[qj]:http://www.freshports.org/sysutils/qjail
[fn]:http://www.freenas.org/
[n4f]:http://www.nas4free.org/
[pf]:https://www.pfsense.org/

## About

*Finch* is FreeBSD *running inside a [`chroot`][ch]*. Finch is best used as a way to extend the functionality of restricted USB-based FreeBSD distributions, usually [FreeNAS][fn] and [NAS4Free][n4f]. For added convenience, Finch also includes the [`qjail`][qj] jails management tool. Since FreeBSD jails are such a popular request.

***Recommended system configuration:***

    # Restricted FreeBSD host <--> FreeBSD-in-a-chroot (a.k.a "Finch") <--> Qjail <--> jails

## Why do I need Finch ?

**FreeNAS, NAS4Free, pfSense:**

* To manage jails with `qjail`, hassle-free.
* To use `pkg install ...`, the official FreeBSD tool otherwise known as `pkg-ng`.
* To have a full, official FreeBSD system image, including ports tree and kernel sources.
* To have all the basics preconfigured for you, and a consistent shell environment.

## Requirements

Host hardware (or VMs) must be running one of the following operating systems.

**Supported Platforms:**

* FreeNAS 9.2 or higher
* NAS4Free 9.2 or higher
* pfSense 2.2 or higher ^1,2
* FreeBSD^3,4 10.0-RELEASE or higher.

**Disk space requirements:**

* Hard disk or SSD, with a UFS or ZFS partition.
* At least 5GB of free space.
* Finch doesn't require any special boot partition.

Requirements for pfSense: ^1 1GB disk image or larger (not "512mb"). ^2 pfSense 2.2 might not be finished, and still in beta testing. You need a 2.2-beta snapshot dated 16th-April-2014 or newer. Available at http://snapshots.pfsense.org/.

Requirements for *FreeBSD*: ^3 The host system must have writable, persistent `/etc` and `/usr/local` folders. ^4 The host system either needs a working `pkg-ng` system, or the packages `sudo` and `bash` pre-installed.

## Install

* Check that your system matches the [Platform Requirements][pr].
* *pfSense only* - follow the [Pre-Install Steps][presteps].
* Login as the `root` user. Then copy-paste these 3 commands into your terminal window:

```
/bin/sh
alias finch-bootstrap="SSL_NO_VERIFY_PEER=YES fetch -q -o - http://git.io/HxXrsw | sh -s --"
finch-bootstrap --help
```
* Typing [`finch-bootstrap --help`][fbh] will show you the available installer options.
* Under normal conditions the default settings should be fine.

To install Finch,

```
finch-bootstrap install --dir "/path/to/finch"
```
Replacing `/path/to/finch` with the full path where Finch is to be installed.

Then follow the platform-specific ***[post install steps][poststeps]***, which you must do after running the installer.

* The Finch "bootstrap" installer will run it's preflight checks and ask for confirmation before continuing.
* You will be guided through the remainder of the installation process.

* Follow carefully any instructions being printed by the `finch-bootstrap` installer. Those messages provide valuable information about your Finch setup and help to avoid any unnecessary issues.

* On FreeNAS / NAS4Free it is worth configuring SMTP email in the Web GUI. Be sure to also set a "to:" destination address in your SMARTD email settings. Then you will be emailed progress updates during installation.

* Why no FreeBSD port / pkg? Reason: Finch is downloaded directly over the internet to your host system. For more details please search the [FAQ][faq]. And look for a section entitled: *Why is there no FreeBSD port for this software?*.

## What next ?

* Why not bury oneself in the Finch **[manpage][fm]**. For that authentic UNIX experience.
* Or consult the **[Using Finch][fu]** page to learn all the basics.
* Head straight on over to the **[Jails How to][jht]** to learn about creating & managing FreeBSD jails.
* Scour through the **[Finch FAQ][faq]** for answers to those burning questions.
* Need to Upgrade? Then it's time to read our comprehensive guide on **[Upgrading Finch][fup]**.
