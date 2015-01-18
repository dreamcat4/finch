
# Using Finch

[bf]:/finch/faq/#toc_8
[man]:/finch/manpage#USAGE
[fr]:#toc_8

[[ toc ]]

## User Setup

* Set your user account to be a member of group `wheel`. ^1
* It is recommended to set `bash` to be your user login shell ^2
* Issue a [`finch refresh`][fr] after changing users or groups.

^1 Only members of the `wheel` administrative group can use Finch. For more information please see the finch [manpage][man]. ^2 Always use a POSIX.2 or Bourne-type compatible shell. Finch installs Bash by default. For more information please see the [bash FAQ entry][bf].

## Finch's shell prompt

There are 3 different Finch prompts. They tell you in a logical manner which of the following 3 environments you are currently in. Requires `bash` or `sh` shell, which use `PS1` for the prompt variable. The file `. /etc/profile` must sourced.

* Host environment, *e.g. FreeNAS, NAS4Free, pfSense*:
</br>**<div><code class="custom-code"><span class="mar">hostname</span> <span class="pur">dir</span><span class="blk">/</span> <span class="blk">user</span><span class="mar">~$</span></code></div>**

* Finch chroot environment:
</br>**<div><code class="custom-code"><span class="mar">hostname</span> <span class="pur">dir</span><span class="blk">/</span> <span class="blk">user</span><span class="mar">\^></span></code></div>**

* Inside a jail:
</br>**<div><code class="custom-code"><span class="grn">jailname</span> <span class="pur">dir</span><span class="blk">/</span> <span class="blk">user</span><span class="grn">~#</span></code></div>**

***Prompt components:***

* **Hostname** - (or jailname, which is also the jail's hostname), critically tells you which machine the window is logged into. This is crucial in multi-host environments.
* **Dir** - (directory), is an important indicator. For brevity we only print the last path component rather than the full path. Since 99% of the time that is enough information. If it's not then just type `pwd` to see the full path.
* **User** - the username of the current login. Used to determine whether or not you're `root`.


***Styling and color scheme:***

* **Host** - In the host, we use a standard and non-descript shell prompt `~$`.
* **Finch** - The "pecking beack" symbol `^>` is a literal representation of the Finch project's avian-themed logo.
* **Jail** - Finally we use the hash `~#` symbol to identify a jail, simply because it looks like the bars of a jail. The green color is also applied to jails, being the color scheme of the Qjail project's website. Green also highlights the protected and sandboxed nature of a jail environment.

## How to 'su' and preserve Finch's login profile

    # Assuming a bash shell
    sudo su -l

    # Or with /bin/sh
    sudo su
    . /etc/profile

## Enter / exit the finch chroot

Most times, we just need to switch in and out of the finch chroot. This is very simple, just type:

    finch chroot
    exit

To do the same thing, but also become the root user:

    sudo finch chroot
    exit

And that's all there is to it.

## Other 'finch' sub-commands

    finch:
         Access the Finch FreeBSD chroot environment. `man finch` for more info.

    Usage:
         $ finch <command> [args]

    Commands:

         chroot    - Chroot into Finch FreeBSD (`chroot /path/to/finch`).
         start     - Mount Finch and start it's rc.d services.
         stop      - Stop Finch's rc.d services and unmount "finch/dev".
         restart   - Same as `finch stop` followed by `finch start`.
         status    - Report on Finch service status (enabled/disabled).
         export    - Map a new command into Finch exports (`finch export <cmd>`).
         -export   - Remove a command from Finch exports (`finch -export <cmd>`).
         <export>  - Run a command listed in Finch exports (`finch <export>`).
         update    - Update the Finch scripts (this program) to the latest version.
         refresh   - Refresh /finch/etc/ files (resolv.conf, localtime & passwd).
         bootstrap - Run the curl-based online installation script `finch-bootstrap`.
         realpath  - The real path to Finch ("$finch_realpath", "/path/to/finch").
         --version - Print the current version of Finch and exit.
         -h,--help - Display this message and exit.

    Realpath:
         /mnt/disk0/finch

    Exports:
         man, pkg, qjail

    Version:
         1.00b, 2180681d76, Fri Mar 21 19:32:06 GMT 2014.

    Bugs:
         Can be reported at http://dreamcat4.github.io/finch/support

    Created by:
         Dreamcat4, dreamcat4@gmail.com (C 2014). FreeBSD License.

## Read the manpages

    # Learn about finch
    man finch

    # Learn about qjail
    man qjail

## Finch exports

* Finch exports are a way to auto-chroot for certain frequently-used commands (for example `qjail`).
* We call such commands `exports` because they are "exports" of Finch into the host's shell environment.
* Exports are just a convenience. You can run any command with `finch chroot <cmd>`. Even if it isn't in Finch's exports list.
* Bear in mind: whilst inside the chroot, the FreeBSD host environment and root tree are inaccessible. It is worth remembering.
* Exports are maintained as a folder of symlinks. Location: `$finch_realpath/etc/finch/exports/`.
* If a command already exists in the host environment, then that will take higher priority and be executed instead. Because it comes first on the search path `$PATH`. For example: `pkg`.
* An INTERACTIVE shell will source `/etc/profile`, and set the finch exports directory onto your $PATH statement.
* Another way to run exports is with `finch <export>`. Doing so explicitly will ensure that the command is only searched for inside the Finch chroot (and not the host's shell also).
* As with all Finch, we rely upon FreeBSD's `chroot` C program. Only the root user, or members of group "wheel" can run Finch commands... so that also includes Finch's "exports".

## Refreshing '/etc' files

It is necessary to refresh certain `/etc` files in the Finch system if they have changed in the host system such as:

* DNS settings in `/etc/resolv.conf`
* Time zone setting in `/etc/localtime`
* Adding or modifying user accounts.
* Adding or modifying user groups.

Just issue a `finch refresh`, `finch restart`, or reboot your host system.

