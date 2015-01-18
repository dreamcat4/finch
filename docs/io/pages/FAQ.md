
# Frequently Asked Questions

[fs]:/finch/support
[fe]:/finch/usage/#toc_4

If it can't be found here, then send an email to dreamcat4@gmail.com and we'll try to answer it.

[[ toc ]]

## Installation

### How To install ... ?

#### zabbix

Link: [zabbix How-To][zh2].

Link: [zabbix configuration examples][zce].

[zh2]:https://gist.github.com/dreamcat4/9e938d53c29340c17958
[zce]:https://gist.github.com/dreamcat4/1935177aafc8bb674675

#### webcamd

Link: [webcamd How-To][wh2].

[wh2]:https://gist.github.com/dreamcat4/32fac8eb6f5db515b68d

#### tvheadend

Link: [tvheadend How-To][th2].

[th2]:https://gist.github.com/dreamcat4/f0e61d35f656afde5df6

#### Universal Media Server (UMS)

Link: [Universal Media Server How-To][uh2].

[uh2]:https://gist.github.com/dreamcat4/1ca69c7f1d215eafcfa7

#### Plex Media Server

Link: [Plex Media Server How-To][ph2].

[ph2]:https://gist.github.com/dreamcat4/f19580cbd31d8f628aca

### Why install FreeBSD into a chroot ?

For some FreeBSD distributions, the base system image `/` is loaded from a compressed archive file into a RAMDISK. All files are wiped clean every boot. This makes it very hard to install 3rd party software. By installing FreeBSD into a chroot, Finch provides a permanent and dedicated space where additional software packages can be installed. In the context of a server OS such as FreeBSD, the FreeBSD chroot is most useful as a staging area for FreeBSD jails. We therefore also include another tool: the `qjail` jails management tool. So that any webservers or other server-side software and daemons can then be installed into their own individual FreeBSD jails.

### Why not just install FreeBSD directly into a jail, rather than a chroot ?

Because jails don't work for some very important things. Jails cannot load kernel modules from inside themselves. You cannot start devfsd for manipulation of the /dev filesystem once a jail has started. Those are all intentional security features of FreeBSD jails, to stop a compromised service running inside the jail from gaining privileged access to the host system.

***Finch IS meant to be:***

A place to manage root-level customizations to your FreeBSD host system. Including loading kernel modules^1, configuring attached USB hardware devices, and starting jails if necessary.

***Finch isn't meant to be:***

The place to run public-facing server software components (Apache, MySQL etc) directly in the chroot. You should run each service (or group of closely associated services) inside it's own individual jail, which may be administered from within Finch.

***Summary:***

By using Finch's chroot as a place to do your host-level customisations, you avoid having to hack or mess around with your host platform (FreeNAS / NAS4Free / pfSense). That is a good strategy because such customisations may interfere in an adverse way with the host's built-in and pre-configured services (those manages in the WebGUI). It also means that when you update the USB stick with a newer version of the host platform, your own host-level customisations will not be wiped out^1 / overwritten by the new USB image, etc.

^1 For kernel modules we recommend you write an rc.d script to run the `kldload` and `kldunload` commands. Put it in /usr/local/etc/rc.d/ and add "scriptname_enable=YES" to Finch's /etc/rc.conf file. Then the rc.d script will be executed during Finch start / stop in the usual fashion.

***Technical Note:***

As an aside, it may be possible *in theory* to run jails inside of a master jail ("nested jails"). Which can solve *some* of the above issues. However jails still can't, and shouldn't, load kernel modules, run devfsd, manipulation of /dev for dealing with attached hardware devices, etc, etc. Furthermore, a nested jails setup would certainly be more complex and less clean to achieve in practice vs a simple chroot.

Disagree? Something amiss? Please drop us an email and we'll try to kindly try to update the F.A.Q. with any further relevant points here. Contact information can be found on the ***[support page][fs]***.

### Why not install Finch onto USB / compact flash ?

Because NAND Flash (of the type found on CompactFlash cards, SD cards, and USB thumbdrives) is a relatively slow and low-endurance storage medium. With a limited write lifecycle and potential of failed writes / bad blocks. They are not a suitable medium for the frequent small write profile demanded by a typical operating system.

### Why only UFS or ZFS partitions ?

Because FreeBSD assumes / expects certain filesystem features. If you install FreeBSD onto a FAT32 partition then it is not clearly known what kinds of background problems might occur. You may have slightly better luck with other, more "UFS-like" filesystems, such as linux EXT2/3/4. However don't assume it's going to work properly. Do your research before attempting such things. Same goes for network-mounted filesystems such as NFS.

### FreeNAS services not working after reboot ?

* You will find that FreeNAS services do not start correctly after Finch installation.
* The problem occurs whilst Finch is installing FreeBSD, during the first reboot.

FreeNAS services are not started until after all `POSTINIT` scripts have finished execution. So after the first reboot (during Finch installation) the `etc/finch/postinit` will take much longer to complete. Anywhere from ***20 minutes*** up to ***1 hour***.

***Symptom:***

* The service will not start up properly after the first reboot.
  For example - ssh: error: "connection refused"
* Other FreeNAS services may also be offline.

***Solution #1:***

* Re-enable the service (toggle the switch on->off->on) in the FreeNAS Web GUI.
  This has been found to work for the ssh service.

***Solution #2:***

* Wait until Finch has finished installing everything.
  The daemon is will start normally once Finch POSTINIT has completed.

### Can I install multiple copies of Finch ?

Yes. Multiple instances of Finch can be installed and operated concurrently alongside one another. 

### Can I move the location of Finch after installation ?

Yes. Finch instances can be moved or relocated at any point after initial installation with the `finch bootstrap move` subcommand. Be careful when moving across disks or filesystems. In those instances, first make a backup.

### Why does Finch install ... ?

#### qjail

Because FreeBSD jails are such a commonly requested feature. The qjail tool does an adequate job. Finch installs qjail and pre-configures it to reduce the number of installation steps that would otherwise be required to arrive at a solution.

#### sudo

Finch isn't trying to prescribe or mandate some specific security model. However in Finch the *chroot* command is being frequently invoked. So sudo provides a convenient and practical way to permit `wheel` users to execute this necessary *chroot* command. Finch will auto-configure sudo by adding the following directive to your sudoers file if it doesn't exist already: `%wheel ALL=(ALL) NOPASSWD: ALL`.

#### bash

* Because the generic FreeBSD bourne-shell `/bin/sh` doesn't have a `-l,--login` option that guarantees `/etc/profile` will be sourced. Wheras `bash -l` works flawlessly.
* The generic FreeBSD bourne-shell `/bin/sh` does not have commandline auto-completion.
* Neither `csh` or `tcsh` have a POSIX.2 or `bourne shell` compatibility mode.
* Because we didn't write any login shell functions for `csh` or `tcsh`.
* Because both FreeNAS and NAS4Free already come with Bash pre-installed.
* Bash is bourne-shell compatible and POSIX.2 compliant without requiring modification or any special compatibility mode.
* Because bash is a modern shell with many advanced features.
* Because bash by is by a large margin the most widespread and commonly-used UNIX shell.
* Because installing Bash does not require very much hard disk space.
* Because installing Bash does not prevent users from using Finch with FreeBSD's generic `/bin/sh`. (They are reminded to `. /etc/profile` however).
* Because installing Bash does not prevent a user from installing other alternative POSIX.2 / bourne-compatible shell(s).
* Because recommending one specific shell to all users does help to reduce the total number of shell-related problems / complaints / issues.

#### nano

* Because so few people voluntarily want to use `vi` as their editor.
* Because FreeBSD's default editor `ee` isn't there on NAS4Free.
* Because FreeBSD's default editor `ee` can often be slow / unresponsive.
* Wheras Nano is a straightforward, no hassle text editor which is small and fast.
* Because FreeNAS and NAS4Free platforms come with Nano pre-installed.

## FreeNAS / NAS4Free

### Will Finch interfere with my FreeNAS / NAS4Free configuration ?

Finch installs everything it needs into it's own subfolder on one of your data drives. Which are entirely seperate and isolated from the host system. Finch can be disabled entirely by removing it's `POSTINIT` boot script from your FreeNAS or NAS4Free configuration.

***Finch will:***

* Add 1 line your host's `/etc/profile` POSIX login shell configuration file.
* Auto configure `sudo` as `%wheel ALL=(ALL) NOPASSWD: ALL` for administrative accounts.
* Symlink the `finch` executable into `/usr/sbin` so that it is on your `$PATH`.

***Finch  won't:***

* Interfere with the FreeBSD Kernel running on your NAS box.^1
* Touch, modify or write to your FreeNAS / NAS4Free configuration.
* Interfere with any running services on your NAS box (ssh, ftp, etc).^2

^1 However you may wish to load extra kernel modules for programs such as VirtualBox. <br>^2 Running intensive 3rd party software inside Finch may slow down your existing NAS services.

### Why do I need Finch ?

**NAS4Free:**

* To manage jails with `qjail`, hassle-free.
* To use `pkg install ...`, the official FreeBSD tool otherwise known as `pkg-ng`.
* To have a full, official FreeBSD system image, including ports tree and kernel sources.
* To have all the basics preconfigured for you, and a consistent shell environment.

**FreeNAS:**

* To manage jails with `qjail`, hassle-free.
* To use `pkg install ...`, the official FreeBSD tool otherwise known as `pkg-ng`.
* To have a full, official FreeBSD system image, including ports tree and kernel sources.
* To have all the basics preconfigured for you, and a consistent shell environment.

### How does Finch compare to 'theBrig' ?

* Finch is not just for hosting jails. You may also recompile your FreeBSD kernel, run VirtualBox or other hypervisors.
* Finch supports other platforms e.g. FreeNAS and the official FreeBSD.
* Finch does not expect that you want to manage your FreeBSD jails manually.
* Finch provides everything you need, already pre-configured for you.
* Finch has no breakable PHP interface. There is no WebGUI like theBrig. Finch is a command line tool.

### Is finch + qjail compatible with FreeNAS jails / plugins ?

Yes and No. FreeNAS uses "Warden" to provide it's jails and plugins features. Warden is a component of PCBSD / trueOS / FreeNAS and produced by iXsystems incorporated. Wheras finch will install the freely available "qjail" FreeBSD port (which is a fork of the "ez-jail" port). With sufficient effort, it may be possible to modify, migrate or re-create an existing FreeNAS jail within qjail.

You can still continue to use all your FreeNAS plugins exactly as before. They are being managed by Warden behind-the-scenes. Wheras for jails both warden and qjail approximate each other's functionality to a large extent. But they do each have their own set of advantages and disadvantages. It is up to you which one you would prefer to use.

### Will qjail conflict with my FreeNAS jails / plugins ?

No. The two environments are entirely independent can happily co-exist. They are not aware of each other.

### Can I recompile my kernel with Finch ?

It's possible. However be aware that the host platform will have it's own build process and some extra kernel patches applied to it. It is a bad idea to mix and match kernel modules with kernels that were build from different revisions.

Also be careful with the kernel IDENT string. This is set by a line near the top of your kernel config file.

You need some reference to `nas4free`, `freenas` or `pfsense` in there. Whichever is applicable. Finch uses `uname` to determine what platform it is on. Without such substring from the kernel IDENT string _will_ cause issues and prevent Finch from starting properly. It is OK to change strings in the kernel IDENT string. Just make sure they also include the word `nas4free`, `freenas` or `pfsense` in there somewhere.

Here is the shellcode Finch uses to determine which platform it is running on:

    if [ "`uname -iv | grep -i freenas`" ] || [ "`uname -iv | grep -i nas4free`" ] || [ "`uname -iv | grep -i pfsense`" ]; then
      # Platform specific code here
    else
      # FreeBSD GENERIC code here
    fi

Once compiled, the new kernel will be installed in to `/path/to/finch/boot/kernel`. You will have to do something with these new files in the `/boot` directory in order to actually boot from them. What is required varies depending upon the host platform. But usually it involves copying some of these files into to the host system's /boot folder. (You are recommended to backup your old kernel files before doing this).

### Can I Compile FreeNAS or NAS4Free in Finch ?

We simply don't know yet. Where are those FreeNAS and NAS4Free developers when you need them eh? Like the several other desirable but untested uses for Finch, will be glad update this section with better information just as soon as someone has **[let us know][fs]** about it.

## General

### What's the difference between FreeNAS / NAS4Free / pfSense ?

Well, here is a very incomplete comparison. It's just the main differences that I noticed. Correct at the time of writing (2014).

<table class="table-striped table-bordered">
  <thead>
    <tr>
      <td><b>Feature</b></td>
      <th>FreeNAS 9.2+</th>
      <th>NAS4Free 9.2+</th>
      <th>pfSense 2.2+</th>
    </tr>
  </thead>
  <tbody>

    <tr>
      <td class="module">
        Primary function
      </td>
      <td>
        NAS
      </td>
      <td>
        NAS
      </td>
      <td>
        Router / firewall
      </td>
    </tr>

    <tr>
      <td class="module">
        Num IRC Users (approx.)
      </td>
      <td>
        248
      </td>
      <td>
        71
      </td>
      <td>
        412
      </td>
    </tr>

    <tr>
      <td class="module">
        Run by
      </td>
      <td>
        iXSystems INC
      </td>
      <td>
        Open Source Project
      </td>
      <td>
        Electric Sheep Fencing
      </td>
    </tr>

    <tr>
      <td class="module">
        WebGUI Responsiveness
      </td>
      <td>
        Slow - Medium
      </td>
      <td>
        Fast
      </td>
      <td>
        Medium - Fast
      </td>
    </tr>

      <td class="module">
        ZFS
      </td>
      <td>
        Yes. Basic web interface.
      </td>
      <td>
        Yes. Comprehensive web interface.
      </td>
      <td>
        No
      </td>
    </tr>

      <td class="module">
        Mounting other disk types:</br>UFS, EXT4, NTFS, FAT32, etc
      </td>
      <td>
        Yes. CLI / fstab only.
      </td>
      <td>
        Yes. Comprehensive web interface.
      </td>
      <td>
        Yes. CLI / fstab only.
      </td>
    </tr>


      <td class="module">
        Password protected settings file?</br>(encrypted config.xml)
      </td>
      <td>
        No
      </td>
      <td>
        Yes
      </td>
      <td>
        Yes
      </td>
    </tr>

      <td class="module">
        User account passwords</br>in the settings file (config.xml)
      </td>
      <td>
        Hashed
      </td>
      <td>
        Plain-text
      </td>
      <td>
        Hashed
      </td>
    </tr>

    <tr>
      <td class="module">
        Recompile Kernel?
      </td>
      <td>
        Yes. Open source.
      </td>
      <td>
        Yes. Open source.
      </td>
      <td>
        No. Closed source.
      </td>
    </tr>

    <tr>
      <td class="module">
        options VIMAGE</br>(better networking for jails)
      </td>
      <td>
        Yes
      </td>
      <td>
        No
      </td>
      <td>
        No
      </td>
    </tr>


  </tbody>
</table>


### Other jails software

Finch comes with the `qjail` program for managing your FreeBSD jails. But that is not the only option out there. What about...

#### ez-jail

It's allright as far as we know. You're welcome to install and use ez-jail instead of qjail if that's what you prefer. Just don't use them *both*... they operate on the same folders and so conflicts are likely to happen. Finch doesn't provide support for ez-jail however it should work just fine.

#### zjail

Zjail is written in Perl, and requires several Perl module dependancies. It doesn't seem to be in the FreeBSD ports tree yet. Their project website is here: http://sourceforge.net/projects/zjails/. It may be possible to try out zjail without it interfering with qjail and similar jails management tools. Since zjail does not use the `/usr/jails` folder.

#### iocage

A re-write of zjail in pure `sh`, without the Perl dependancy. This project isn't in the FreeBSD ports tree yet. Requires FreeBSD 10-RELEASE amd64.

* http://iocage.readthedocs.org/en/latest/index.html
* https://github.com/pannon/iocage

#### warden

Unfortunately (at time of writing) Warden isn't available from the FreeBSD ports tree and FreeBSD pkgng repositories. We hope that situation may change in the future.

Warden source code:

* https://github.com/freenas/freenas/tree/master/nas_ports/freenas/pcbsd-warden
* https://github.com/freenas/freenas/tree/master/src/pcbsd/warden
* https://github.com/pcbsd/pcbsd/tree/master/src-sh/warden

^ Not sure which one of those is the upstream repository. You'd have to ask iXSystems.

#### docker

Haven't tried it. Python-based.

* http://www.docker.com
* https://github.com/dotcloud/docker

#### BSDploy

Haven't tried it. Python-based.

* http://www.freshports.org/sysutils/bsdploy/
* http://docs.bsdploy.net/en/latest/
* https://github.com/ployground/ploy_ezjail

#### Ansible

Haven't tried it. Python-based.

* https://ep2014.europython.eu/en/schedule/sessions/93/
* https://pypi.python.org/pypi/mr.awsome.ezjail/1.0b7
* https://github.com/tomster/mr.awsome.ezjail
* https://github.com/jdauphant/ansible-freebsd-playbooks
* https://github.com/tomster/ezjail-ansible
* https://dan.langille.org/2013/12/23/accessing-freebsd-jails-over-openvpn/

#### Chef Metal

Chef metal does not provide support for FreeBSD Jails at this time.

#### Jails for Continuus Integration

The Java-based continuus integration server 'Jenkins' supports FreeBSD (but not jailsspecifically). There is also a Chef Cookbook for provisioning a Jenkins CI server which references the keyword 'jails'.

* https://mywushublog.com/2013/04/building-packages-for-freebsd
* https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins
* http://www.freshports.org/devel/jenkins
* https://github.com/opscode-cookbooks/jenkins

#### cbsd

Yet another jails tool. Have not tried it. It's available from `sysutils/cbsd` in the FreeBSD ports tree. Or `pkg install cbsd`.

Documentation at -

* Website: http://www.bsdstore.ru
* Github: https://github.com/olevole/cbsd


### How do I install my own programs in Finch ?

Lets say you want to use `ezjail`^1 instead of `qjail`. First we would install ezjail into our Finch system:

    # Enter the finch chroot environment, as root
    sudo finch chroot

    # Update local pkgng database, to avoid 'failed checksum' for 'pkg install'
    pkg update -f

    # Either a) install with pkg-ng
    ASSUME_ALWAYS_YES="yes" pkg install "ezjail"

    # Or b) compile from the ports tree
    cd "/usr/ports/sysutils/ezjail" && make "config-recursive" "install" "clean"

    # If it has an rc.d service, enable that in Finch's rc.conf file
    sysrc "ezjail_enable=YES"

    # Leave the chroot
    exit

Now we can add the command to our exports. The Finch exports feature is explained on the **[usage page][fe]**.

    # Add the command to our finch exports list
    finch export "ezjail-admin"

    # Check that it can be invoked from the host environment
    ezjail-admin --help
    man ezjail

***Note:*** ^1 It is not recommend to install the `ez-jail` program if you are also intending to use the qjail program. It is merely an example. Conflicts may arise in the `/usr/jails` directory between qjail and ezjail.

### Can I run VirtualBox VMs in Finch ?

There has been some preliminary investigations into VirtualBox. The main obstacle is that VirtualBox requires kernel modules. And those must be build to be exactly the same kernel version as the host platform. The correct build environment with which to produce the right version of these VirtualBox kernel modules can be difficult to obtain. It may be necessary to first download a specific revision of FreeBSD source files under SCM, and "make buildworld", or something similar. The matter is not helped in that VirtualBox is such a big and complicated piece of software, which in itself has many dependancies which can also take a very long time to compile.

So, for a trouble-free life, the general recommendation is to try and avoid VirtualBox altogether and instead use FreeBSD jails wherever possible.

### Can I run "bhyve" VMs in Finch ?

In truth we simply aren't sure yet. Why not be the first to report back your findings? **[Let us know][fs]** what happens. Same goes for `xen` hypervisor.

### Can I run an Xserver / X-Windows in Finch ?

Again we don't know / haven't tried. **[Let us know][fs]** what happens if you have tried this.

### Finch's colorful prompt dissapears after 'su' or 'sh' command

If you type `su <user>` or `sh`, your prompt may turn into `# `, or start looking like this:

    [user@hostname /path/to/pwd]

***Solution:***

* Type `. /etc/profile` to re-source the Finch login profile and reload the `PS1=` prompt.
* Use `sudo su -l` instead of plain `su`.

### I get a pkg error (pkg-ng)

There are many pkg errors. Unfortunately Finch cannot give direct support and in most cases you are likely to arrive at a solution far quicker by searching with google, or scouring the FreeBSD Forums.

However one (1) such error is known to occur upon entering an NON-interactive shell:

    # pkg install ...
    pkg: PACKAGESITE in pkg.conf is deprecated. Please create a repository configuration file
    Updating repository catalogue
    pkg: Warning: use of ftp:// URL scheme with SRV records is deprecated: switch to pkg+ftp://
    pkg: ftp://ftp.FreeBSD.org/pub/FreeBSD/ports/amd64/packages-current/Latest//digests.txz: File unavailable (e.g., file not found, no access)
    pkg: Unable to find catalogs

The cause of the problem was never discovered. But the solution was to exit from the current shell. And then instead run `pkg` from within an _interactive_ login shell, for example `bash -l`.

### What is the 'subr' folder for?

Most of the the Finch scripts are held within a folder named `subr`. It simply means *subroutines* and is (for multi-file sh scripts) an analogue of the 'C' language's `include/`. The name subr is taken from FreeBSD's naming of it's `rc.conf` subroutines file `/etc/rc.subr` (see `man rc.subr`).

### Why are Finch scripts prefixed with 'ibps_*' ?

For manageability, Finch is split into many individual subroutine files, each one with a specific purpose. Each subroutine source file is prefixed with an matrix identifier which can be any appropriate combination of these `ibps` identifiers, where `i=install`, `b=boot`, `p=profile`, and `s=shutdown`. In the special case of `__p__` we also load this same set for the functions needed by the Finch executable.

It is a crude dependancy loading mechanism, which is performed by the script in `subr/_____load`. The purpose of the mechanism is to load only the necessary sub-set of subroutine files (as marked by the developer) and avoid loading functions that we don't need for that given task. Rather than all of them all of the time. Thus keeping load times under control for the various Finch shell scripts.

## FreeBSD

### Why is there no FreeBSD port for this software?

Because the "finch" name is already being used by another FreeBSD port "netim/finch". So having a FreeBSD of this software too would require some reasonable solution in order to address the naming conflict.

Reasons why it does not matter:

* Because at time of release { FreeNAS, NAS4Free, pfSense } do not natively support installation of software via FreeBSD ports or pkgng. And this accounts for 99% of the Finch user base.

* The fetch based online installer works fine. And can also uninstall a copy of Finch, removing all traces of it.

* The same fetch based mechanism also provides rapid updates via `finch update`. This helps with rapid bug fixing. Which is not possible with FreeBSD ports / packages.

* For others who already have a working FreeBSD ports or pkgng, then the usefulness of Finch is largely mitigated. Indeed, a lot of the Finch source code exists to work around quirks in { FreeNAS, NAS4Free, pfSense }. And that is not needed if you have the official FreeBSD.

Reasons why it should matter:

* It would improve collaboration with others involved in the FreeBSD project.
* Easier to install on the official version of FreeBSD.
* Easier for platform providers to include / bundle Finch into their own official builds.

### Why call this project 'finch' if there is already and existing FreeBSD port called 'finch' ?

On balance we decided that there was no significant harm to come from also using Finch as our project's name. Because "Finch" is the most apt, compelling, concise, and fit-for-purpose name.

As a frequently-used command, we needed something that is both easily remembered, and easy to type on the keyboard. So `finch` fitted the bill perfectly.

The other project can be found as `net-im/finch` in the FreeBSD ports tree. It shouldn't present any major conflict as in most cases it's not likely that both are installed.

### How can I resolve a naming conflict with 'netim/finch' ?

As a system utility, we install *this finch* into `/usr/sbin/`. Wheras the *finch IM client* installs it's *finch command* into `/usr/local/bin/`. That already avoids any direct files conflict.

The *finch im client* happens to be the one with a lower priority on FreeBSD's default search path. So we recommend renaming the other project's executable by symlinking it as `finch-im`. For example:

    $ ln -sf "/usr/local/bin/finch" "/usr/local/bin/finch-im"

For man pages `man 1 finch` will display the man page for the net-im client. Wheras `man 8 finch` will display [the manpage for this project][fman].

[fman]:manpage

### Will you ever write a 'C' implementation of Finch ?

No plans for doing this. But will support and co-operate with any developer(s) wishing to improve or re-purpose the Finch tool.

**Suggested improvement:**

Currently we use FreeBSD's stock `chroot (8)` command line program. But a specially compiled 'C' program could be run setuid root, in theory calling FreeBSD's chroot(3) 'C' function with regular user permissions. Which would open the possibility for finch to also work for ordinary user accounts.

### How do I trace program execution in FreeBSD ?

There are several tools available.

    # Trace a shell script
    set -x
    # <commands>
    set +x

    # Trace the 'C' system calls of a process
    truss

    # Trace the kernel calls of a process
    ktrace

Of course, you may also be able to enable logging in the application itself.

## Qjail

### Why isn't "ping" working in my jails ?

Because raw sockets (ICMP "ping") is disabled by default. You can switch this feature on/off at any time.

    # Enable raw sockets (allow "ping" command)
    qjail config -k "$jailname"

    # Disable raw sockets
    qjail config -K "$jailname"

### qjail config -p <cpuset> gives the following error - jail: test: unknown parameter: cpuset.id

This feature is documented both in the `qjail` manpage and the `jail` manpage. However it doesn't seem to work. Tested as broken on FreeBSD 9.1, 9.2, 10.0, on single & dual core CPU.

    # For a quad-core CPU: "cpuset -g | grep -o -e mask.*" shouly say "mask: 0, 1, 2, 3"
    # Then valid cpu sets might be: "0", "0-3" "2,3" etc, where "0" is the first core.
    jail_cpu_set="0"
    qjail config -p "$jail_cpu_set" "$jailname"

    qjail start myjail

    jail: test: unknown parameter: cpuset.id
    Error: /usr/sbin/jail failed to start jail myjail.
    because of errors in jail.conf file.

