# Upgrading Finch FreeBSD

[fu]:http://www.freebsd.org/cgi/man.cgi?query=freebsd-update

[[ toc ]]

## Introduction

Let's say we installed Finch onto a FreeBSD 9.2-RELEASE host system. But now we would like to upgrade to FreeBSD 10.0-RELEASE. Then we must also upgrade Finch to match. Otherwise the finch chroot environment may not function properly until both systems are put back on the same page. Same goes for any jails you may have installed inside Finch.

We can upgrade Finch FreeBSD in much the same way as any official FreeBSD distribution with [`freebsd-update`][fu]. However for a Finch installation we must add some extra steps at certain points during the process. We can also upgrade any jails, if they are present.

### Warning

We cannot know beforehand or be held responsible for any failures / breakages / data loss caused by freebsd-update. You have been warned. That having been said, FreeBSD update is not commonly known to fail or leave your system broken. Breakages tend to be few, minor in nature, and accompanied by a documented procedure with which to apply a relevant fix or workaround.

If you have sufficient time and disk space then consider making a full backup beforehand. Just in case anything else goes wrong. The power might be interrupted, an unforeseen error may occur, etc.

### Check your EDITOR and PAGER

In all likelihood you may be asked to merge the occasional configuration file. In which case freebsd-update will open the program set in your `$EDITOR` environment variable. Not everyone can use "vi". So please be adequately prepared with an appropriate text editor *beforehand* which you feel comfortable with. Same goes for the pager. You might not need to change anything. Finch should have already set them up for you as `nano`, and `less`.

    # What's your current default text editor ?
    echo "$EDITOR"

    # Possible editors: `vi`, `ee`, `nano`.
    export EDITOR="nano"

    # Check that it is on your "$PATH".
    command -v "$EDITOR" # or `which "$EDITOR"` for tcsh shell

    # freebsd-update also uses your "$PAGER"
    export PAGER="less"

# Minor updates to FreeBSD

How to update the **patch level**. For example `9.2.1-p9` --> `9.2.1-p21`. Minor updates are for bugs, security fixes etc. Do the same as a regular FreeBSD update. Nothing extra special needs to be done for Finch.

    # Enter the finch chroot environment, as root
    sudo finch chroot

    # Updating can be done interactively at any time
    freebsd-update fetch install

    # Go ahead and install the new patch level
    freebsd-update install

    # (optional) Update binaries inside your jails
    qjail update -b

    # To revert the last set of applied changes
    freebsd-update rollback

You may also check for updates in a cron job, and recieve an email report when new updates become available. However installation of updates still needs to be performed manually. Consult the [`freebsd-update`][fu] manpage for more details.

# Major upgrade of FreeBSD

How to update to a higher **point release**, or a **major version**. For example `9.1-RELEASE` --> `9.2-RELEASE` or `9.2-RELEASE` --> `10.0-RELEASE`.

***Note:*** You may upgrade Finch *before or after* upgrading the host system. The process can be done *either way round*. However the procedure is a little bit different in each case. 

## AFTER the host system

Use this procedure if you need to upgrade Finch AFTER upgrading the host system.

    # We assume you have already followed the official proceedure
    # for upgrading FreeBSD on your host system. For example:
    #
    # On FreeNAS / NAS4Free:
    #   * Backup config. Upgrade FreeNAS / NAS4Free. Restore config.
    #
    # On FreeBSD GENERIC: 
    #   * Ran $ freebsd-update as per official FreeBSD guidelines.
    #

    # Enter the finch chroot environment, as root
    sudo finch chroot

    # Check the current version of finch
    cat "/var/db/finch/installed"
    FreeBSD-amd64-9.2-RELEASE

    # Put here the newer target version of FreeBSD you want to upgrade to
    new_release="9.3-RELEASE"

    # We must spoof the "uname" command to match the contents of "/var/db/finch/installed"
    # to avoid the error "freebsd-update: Cannot upgrade from X.Y-RELEASE to itself".
    uname_override on

    # Fetch the upgrade. You will be prompted to confirm the action.
    # Please note that this step usually takes a while. Maybe an hour.
    freebsd-update -r "$new_release" upgrade

    # Return the "uname" program back to normal.
    uname_override off

    # Apply the changes. Upgrade Finch.
    # This is an an interactive task. You may be asked to merge certain files.
    freebsd-update install

    # <-- ... snip ... -->

    # If all goes well, you should see this message at the very end:
    Kernel updates have been installed.  Please reboot and run
    "/usr/sbin/freebsd-update install" again to finish installing updates.

    # We are asked to reboot into the new FreeBSD kernel. Then rerun the same command.
    # Hoever we are already on the new Kernel. so just run it again (no reboot required).
    freebsd-update install

    # You may have got a few errors like: "ln: ///.cshrc: No such file or directory"
    # Sorry the cause isn't known.
    # We recommend to ignore such errors if they are about non-essential files.

    # Tell Finch that we have updated FreeBSD. So Finch doesn't keep pestering us about it.
    echo "FreeBSD-`uname -m`-`uname -r | cut -d- -f1-2`" > "/var/db/finch/installed"

    # Optional

    # For MAJOR version updates only (FreeBSD 9 -> 10). SKIP for MINOR versions (9.1 --> 9.2).
    # Brute-force rebuild of all installed ports. BEWARE: Can often lead to breakages or build errors.
    portmaster -f

    # For jails, update the jails' binaries.
    qjail update -b

    # Remove any original FreeBSD distfiles (if present) - they are no longer valid.
    rm -rf /var/distfiles/finch

    # All done.

## BEFORE the host system

Use this procedure if you need to upgrade Finch BEFORE upgrading the host system.

    # Enter the finch chroot environment, as root
    sudo finch chroot

    # Check the current version of finch
    cat "/var/db/finch/installed"
    FreeBSD-amd64-9.1-RELEASE

    # Put here the newer target version of FreeBSD you want to upgrade to
    new_release="10.0-RELEASE"

    # Fetch the upgrade. You will be prompted to confirm the action.
    # Please note that this step usually takes a while. Maybe an hour.
    freebsd-update -r "$new_release" upgrade

    # Apply the changes. Upgrade Finch.
    # This is an an interactive task. You may be asked to merge certain files.
    freebsd-update install

    # <-- ... snip ... -->

    # If all goes well, you should see this message at the very end:
    Kernel updates have been installed.  Please reboot and run
    "/usr/sbin/freebsd-update install" again to finish installing updates.

    # At this point, we assume you will now follow the official proceedure
    # for upgrading FreeBSD on your host system. For example:
    #
    # On FreeNAS / NAS4Free:
    #   * Backup config. Upgrade FreeNAS / NAS4Free. Restore config.
    #
    # On FreeBSD GENERIC: 
    #   * Run $ freebsd-update as per official FreeBSD guidelines.
    #

    # Host system updates completed successfully ?
    # At this point, we assume you have booted into the new kernel.

    # Re-enter our chroot environment
    sudo finch chroot

    # Finish applying Finch's FreeBSD updates.
    freebsd-update install

    # You may have got a few errors like: "ln: ///.cshrc: No such file or directory"
    # Sorry the cause isn't known.
    # We recommend to ignore such errors if they are about non-essential files.

    # Update our records, and so that finch does not keep pestering us to update FreeBSD.
    echo "FreeBSD-`uname -m`-`uname -r | cut -d- -f1-2`" > "/var/db/finch/installed"

    # Optional

    # For MAJOR version updates only (FreeBSD 9 -> 10). SKIP for MINOR versions (9.1 --> 9.2).
    # Brute-force rebuild of all installed ports. BEWARE: Can often lead to breakages or build errors.
    portmaster -f

    # For jails, update the jails' binaries.
    qjail update -b

    # Remove any original FreeBSD distfiles (if present) - they are no longer valid.
    rm -rf /var/distfiles/finch

    # All done.
