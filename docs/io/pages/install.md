[fbh]:#toc_1
[presteps]:#toc_2
[poststeps]:#toc_12
[fup]:/finch/upgrading
[pr]:/finch/#toc_3
[faq]:faq

[[ toc ]]

# Install

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

# Installer options

    $ finch-bootstrap --help

    Usage:
        $ finch-bootstrap "command" [--options]

    Example:
        $ finch-bootstrap install --dir "/mnt/disk0/finch"

    Commands:

        install   - Install a new copy of Finch FreeBSD.
        uninstall - Uninstall a copy of Finch FreeBSD.
        update    - Update the finch command and finch scripts to the latest version.
        move      - Move/rename the paths/locations to this copy of finch.

    Options:

        -d, --dir "{realpath}"
             The full installation "/path/to/finch". Defaults to "\$PWD/finch".
             ~ if not set a new subdirectory will be created here named "finch".
             Internally referred to as "$finch_realpath" - the chroot directory.

        -y, --yes
             Do not prompt for user confirmation before continuing. Useful
             for unattended operations or launching from other scripts.

        -f, --force
             Do not exit when a potential problem is encountered. Continue
             regardless of all warnings and errors.

        -e, --dest-dir "{dest_dir}"
             (move) A destination path where to move this installation.
             Where the current location is specified by "--dir {realpath}".

        -t, --txz-distfiles-dir "{txz_distfiles_dir}"
             (install) A local folder from which to obtain the FreeBSD ".txz"
             distribution files from ("distfiles"), "base.txz"... etc. With this
             option *nothing* will be downloaded from ftp://ftp.freebsd.org.
             You will be locally responsible for ensuring a correct set of
             distribution files is present. All "*.txz" files found in the folder
             will be unpacked / installed to the target directory ("--dir {dir}").

        -x, --debug
             Debugging output. Switches on "set -x" to echo all commands.

        -h, --help
             Display this message and exit.

    Bugs:
        Can be reported at http://dreamcat4.github.io/finch/support

    Created by:
        Dreamcat4, dreamcat4@gmail.com (C 2014). FreeBSD License.

# Pre-Install steps

## pfSense

Finch requires at least 5GB of hard disk space on a UFS partition. Finch should only be installed on a regular hard disk and not on a USB Flash drive.

If you have already installed pfSense onto hard disk, then the drive where you have installed pfSense may already be suitable and meet those requirements.

### Prepping a new hard disk

If you are running pfSense from an embedded image (which is the best way and recommended), then you will have to manually format, mount and prep the hard disk. These steps assume a blank or unformatted hard disk is already installed into the target machine

    # Ensure you are in a POSIX.2 (ISO-compliant) shell. To avoid any confusion.
    /bin/sh

    # 1.a. Locate and identify which device name your hard disk is represented by
    dmesg | grep -E 'ad[0-9]|da[0-9]'

    # 1.b. Don't get this wrong. Double-check.
    camcontrol devlist

    # 1.c. Check for any existing partitions on attached disks
    ls -l /dev/

    # Put here the device name of your hard drive. Ours was "/dev/adz1"
    disk="adz1"

    # Destroy previous partition table. This will ruin any data on the disk
    dd if="/dev/zero" of="/dev/$disk" bs="64k" count="100"

    # Format the disk as UFS. Creates one big partition
    newfs "/dev/$disk"

    # Remount the root "/" filesystem as read-write
    [ "$(mount | grep -e "on / " | grep read-only)" ] && mount -o noatime -u -w "/"

    # Put here the mountpoint for your new drive
    mountpoint="/mnt/disk0"

    # Create the folder for our mountpoint
    mkdir -p "$mountpoint"

    # Add new fstab entry
    echo "/dev/$disk $mountpoint ufs rw 1 1" >> "/etc/fstab"

    # Check that it worked
    mount -a && df -h


### Getting pfSense to mount your hard disk(s) at boot time

We have done everything correctly, but pfSense still needs some slight modification to respectfully mount your `fstab` file, as it should. Yet pfSense / nanoBSD will not automatically do a `mount -a` during boot time like regular FreeBSD-GENERIC. Sensible? No. Easily fixed? Yes.

Run this script to correct the issue. It will instll a small boot script to `mount -a` and perform `fsck` check if necessary^1. Just copy-paste these lines into your terminal (as root):

    /bin/sh
    alias pfmount_install="SSL_NO_VERIFY_PEER=YES fetch -q -o - http://git.io/NBLjxw | sh -s --"
    pfmount_install

    # Check that your fstab disk mounts are persistent across reboots
    reboot
    df -h
    cat /etc/fstab

### Getting pfSense to remember your hard disk(s) after upgrades


Whenever you upgrade or re-install pfSense, your fstab file and also the fstab boot script will disappear. To get around this issue requires the help of two Packages: `Backup` and `ShellCmd`. We will use Backup to save / restore our fstab file. And ShellCmd will ensure that the fstab boot script is reinstalled after upgrades.

#### Install the 'Backup' Package

* In the pfSense Web GUI

Go to `System|Packages`

Go to `Available Packages|System`

* Click `+` next to the `Backup` Package, and install it.

#### Install the 'ShellCmd' Package

* In the pfSense Web GUI

Go to `System|Packages`

Go to `Available Packages|Services`

* Click `+` next to the `Shellcmd` Package, and install it.

#### Add bootup script

This script ensures that the fstab boot script is present. If absent the necessary boot scripts will be downloaded again from Github, and re-installed. This may happen for example after upgrading pfSense. (You will still need to restore your fstab file manually however).

* In the pfSense Web GUI

Go to `Services|ShellCmd`

* Click `+` and add the following `shellcmd` script:

```
[ -x "/etc/rc.mount_-a" ] || SSL_NO_VERIFY_PEER=YES fetch -q -o - http://git.io/NBLjxw | sh -s --
```

#### Backup '/etc/fstab'

* In the pfSense Web GUI

Go to `Diagnostics|Backup Files/Dir`

* Click `+` icon to add a new file to our backup list.

Input the following text fields

* Name: fstab
* Path: /etc/fstab

* Click the "Save" button to save changes.

* Click the "Backup" button to download the backup .tgz file in your web browser.

***<span class="mar">Take note!</span>*** If you remove, swap, or attach new disks, then you may need to change the contents of your fstab file. Remember to backup your new fstab file if you ever have to change it.

#### Restore '/etc/fstab'

After upgrading pfSense, it is necessary to restore this file from your downloaded `pfsense.bak.tgz` archive.

* In the pfSense Web GUI

Go to `Diagnostics|Backup Files/Dir`

* Click the "Choose File" button and select your local `pfsense.bak.tgz` archive in your file chooser. This should be the last backup of fstab you originally downloaded and saved to your local workstation / desktop / laptop computer.

* Click "Upload". Click "Restore".

* Reboot your machine.


# Post-Install Steps

Choose your platform from the list below.

* [NAS4Free][pisnf]
* [FreeNAS][pisfn]
* [pfSense][pispf]
* [FreeBSD-GENERIC][pisfg]

[pisnf]:#toc_13
[pisfn]:#toc_17
[pispf]:#toc_22
[pisfg]:#toc_27

## NAS4Free

These steps should be followed after installation.

### Configure administrator accounts

Finch will automatically configure the root account for you. These steps should be followed for any other normal users who you want to be administrators, and use Finch too.

* In the NAS4Free Web GUI Go to `Access|Users`
* Click the spanner icon, `Edit User`
* Select Group **`wheel`**
* Select **`bash`** as The User's login shell.
* Click --> `Save` --> `Apply changes`.


### Add bootup / shutdown scripts

* In the NAS4Free Web GUI

Go to `System|Advanced|Command Scripts`

* Click `+` and add the following `POSTINIT` script:

```
/path/to/finch/etc/finch/postinit
```
* Click `+` and add the following `SHUTDOWN` script:
  
```
/path/to/finch/etc/finch/shutdown
```

***<span class="mar">Take note!</span>*** The above text `/path/to/finch` is not a real path. Instead you must put the real directory where Finch is located on the filesystem. For example, if you are installing Finch into `/mnt/disk0/finch`, then the correct startup and shutdown commands would be:

    /mnt/disk0/finch/etc/finch/postinit
    /mnt/disk0/finch/etc/finch/shutdown

### Start the Finch FreeBSD installation process

* Reboot your NAS4Free system. Installation will begin on next boot.
* To check progress login on the command line and type:

```
tail -99999 -f /path/to/finch/var/log/finch/install.log
```
* Installation will take anywhere from 20 minutes up to 1 hour.

## FreeNAS

These steps should be followed after installation.

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

### Configure root & administrator accounts

* In the FreeNAS Web GUI Expand `+ Account` --> `+ Users` --> `View Users`
* Select the account from the list of all users. Click to highlight the entry.
* Click the `Modify User` button that appears.
* Select Shell: **`bash`**.
* Select `Auxilary Groups` >> **`wheel`**.
* Click `OK` to close the window and save changes.

### Add bootup / shutdown scripts

* In the FreeNAS Web GUI:

Expand `+ System` --> `+ Init/Shutdown Scripts` --> `Add Init/Shutdown Script`

* Select Type: `Script` and add the following `POSTINIT` script:

```
/path/to/finch/etc/finch/postinit
```
* Select Type: `Script` and add the following `SHUTDOWN` script:

```
/path/to/finch/etc/finch/shutdown
```

***<span class="mar">Take note!</span>*** The above text `/path/to/finch` is not a real path. Instead you must put the real directory where Finch is located on the filesystem. For example, if you are installing Finch into `/mnt/disk0/finch`, then the correct startup and shutdown commands would be:

    /mnt/disk0/finch/etc/finch/postinit
    /mnt/disk0/finch/etc/finch/shutdown

### Start the Finch FreeBSD installation process

* Reboot your FreeNAS system. Installation will begin on next boot.
* To check progress login on the command line and type:

```
tail -99999 -f /path/to/finch/var/log/finch/install.log
```
* Installation will take anywhere from 20 minutes up to 1 hour.

## pfSense

### Configure admin accounts

Create user account(s) which are a member of the `admins` group.

* In the pfSense Web GUI

Go to `System|User Manager`

Create or edit a user by clicking `+` or `e`.

In the `Group Memberships` section:

* Highlight `admins`, and Click `>` to make the user a member of the `admins` group

* Click the `Save` button to save changes.

### Install the 'ShellCmd' Package

* In the pfSense Web GUI

Go to `System|Packages`

Go to `Available Packages|Services`

* Click `+` next to the `Shellcmd` Package, and install it.

### Add bootup script

* In the pfSense Web GUI

Go to `Services|ShellCmd`

* Click `+` and add the following `shellcmd` script:

```
/path/to/finch/etc/finch/postinit
```

***<span class="mar">Take note!</span>*** The above text `/path/to/finch` is not a real path. Instead you must put the real directory where Finch is located on the filesystem. For example, if you are installing Finch into `/mnt/disk0/finch`, then the correct startup command would be:

    /mnt/disk0/finch/etc/finch/postinit

### Start the Finch FreeBSD installation process

* Reboot your pfSense system. Installation will begin on next boot.
* To check progress login on the command line and type:

```
tail -99999 -f /path/to/finch/var/log/finch/install.log
```
* Installation will take anywhere from 20 minutes up to 1 hour.
* During this time certain pfSense services may be unavailable.

## FreeBSD-GENERIC

These steps should be followed after installation.

### Configure root & administrator accounts

* Be a member of group wheel

```
$ "pw user mod $USER -G wheel"
```
* Set \`bash\` or \`sh\` as your default login shell

```
$ "pw user mod $USER -s /usr/local/bin/bash"
```
* Close any open terminals or shells and log back in again

```
$ ". /etc/profile" will re-source profile for this shell
```
* Reboot or issue "finch refresh" on the command line.
