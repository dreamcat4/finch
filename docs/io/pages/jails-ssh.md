# Jails - Ssh

[cf]:http://www.commandlinefu.com/commands/view/188/copy-your-ssh-public-key-to-a-server-from-a-machine-that-doesnt-have-ssh-copy-id

[[ toc ]]

This page explains how to enable ssh access for your jails. After enabling ssh access, a password login to your jails will be possible. The exception being the [`qjail console`][qc] command which does not need any password.

To configure passwordless ssh access later on, please also check ***[these instructions][cf]*** on [commandlinefu.com][cf]. Where you can learn how to scp over ssh keys (`~/.ssh/id_rsa.pub`) and edit the `~/.ssh/authorized_keys` file.

# 4 ways to enable ssh

[qc]:#toc_2
[finch_ssh]:#toc_3
[finch_ssh_root]:#toc_6
[manual_ssh]:#toc_7

***<span class="mar">RECOMMENDED</span>***

* [1. Terminal access via 'qjail console'][qc].

    your computer ---> ssh ---> FreeNAS / NAS4Free ---> qjail console

* Using either [2. the `finch-ssh` jails template][finch_ssh] or [3. `finch-ssh-root` jail template][finch_ssh_root]. (and *NOT* the one named "ssh-default").

The template "finch-ssh" will forbid root account ssh logins. Wheras "finsh-ssh-root" will permit ssh logins for all user accounts, inclusive of the `root` user.

* [4. Manually turn on ssh for an existing jail][manual_ssh]. Because you might have already created your jail without the necessary ssh flavor, or have deferred the decision to switch on ssh until later on.

***<span class="mar">NOT RECOMMENDED</span>***

* 5. The template provided by qjail, labeled `ssh-default`. The method documented on the qjail manpage. That one is enabled by "qjail create -c", or `qjail config -h`. *REASON:* we do not encourage it's use because you are forced into using a specific username for your ssh account. Finch installs for you better ssh templates ([2.][finch_ssh] and [3.][finch_ssh_root]), which improve control over which user accounts may be allowed to access your jails.

## Terminal access via 'qjail console'

By default ssh will not be enabled on that jail. SSh often isn't required because we can just ssh into the FreeBSD host machine then access any of our jails from the commandline.

The command `qjail console $jailname` will launch a root login shell and enter you into the chosen jail.

    ssh "$freebsd_host"
    sudo qjail console "$jailname"

Or you may prefer to perform both actions together as a single step:

    ssh "$freebsd_host" sudo finch chroot qjail console "$jailname"

Which can be made into a simple `~/.profile` shell function, script or Windows batch file. It takes the jail's name as a parameter. For example:

    qjail-remote-console ()
    {
      if [ "$#" -gt "0" ]; then
        # The freebsd system where finch and qjail are installed (FreeNAS / NAS4free)
        local freebsd_host="192.168.1.XXX"

        ssh "$freebsd_host" sudo finch chroot qjail console "$@"

      else
        echo "usage: qjail-remote-console $jailname"
      fi
    }

**Note:** The `qjail console` command only provides a login for tty / terminal access. It does not enable ssh inside the jail. Almost all other ssh-based services are designed to connect to a real ssh daemon and won't work with this method. However you may feed multiple commands into the shell seesion in the following way:

    echo "$some_cmd1; $some_cmd2" | qjail-remote-console $jailname

## Create a jail with ssh enabled

This flavor does not permit ssh logins for the root account.

### Part A - Create the jail

    # Enter the finch chroot environment, as root
    sudo finch chroot

    # Read the page "jail-ip-addresses" before choosing a jail IP address
    jail_ip="192.168.1.202"
    jail_loopback="lo0|127.0.0.202"

    # Give an appropriate server name to your jail
    jailname="ssh"

    # Create a jail with the "finch-ssh" flavor
    qjail create -f finch-ssh -4 "$jail_ip,$jail_loopback" "$jailname"

    # Enable unix sockets
    qjail config -k "$jailname"

    # Start the jail
    qjail start "$jailname"

### Part B - Create an account for ssh'ing into your jail

In the example below we assume that you want a wheel account to use for administering your jail. However superuser privileges are not a requirement for ssh'ing. In which case just omit the `"-G wheel"` part to create a regular account.

    # 1. Login locally (as root)
    qjail console "$jailname"

    # 2. Create an account
    username="admin" # put here your own username
    pw user add "$username" -c "$username's account" -m -G wheel

    # 3. Set a password. Otherwise we are not permitted to login over ssh
    passwd "$username"
    exit

    # Test the connection - ssh into the jail
    username="admin" # put again your chosen username
    ssh "${username}@${jail_ip}"

## Create a jail with ssh enabled for root

This flavor does permit ssh logins for the `root` account. And regular users too.

    # Enter the finch chroot environment, as root
    sudo finch chroot

    # Read the page "jail-ip-addresses" before choosing a jail IP address
    jail_ip="192.168.1.203"
    jail_loopback="lo0|127.0.0.203"

    # Give an appropriate server name to your jail
    jailname="root-ssh"

    # Create a jail with the "finch-ssh-root" flavor
    qjail create -f finch-ssh-root -4 "$jail_ip,$jail_loopback" "$jailname"
    
    # Enable unix sockets
    qjail config -k "$jailname"

    # Start the jail
    qjail start "$jailname"

    # Set a password. Otherwise we are not permitted to login over ssh
    qjail console "$jailname"
    passwd "root"
    exit

    # Test the connection - ssh into the jail
    username="root" # put again your chosen username
    ssh "${username}@${jail_ip}"

## Turn on ssh in an existing jail

For an existing jail, we can manually copy over the same ssh configuration files, as would have been used in creating a new jail.

    # Set to the name of your existing jail
    jailname="nginx"

    # 1. Either forbid the root account to have ssh access
    cp -Rf "/usr/jails/flavors/finch-ssh/etc/ssh" "/usr/jails/${jailname}/etc/"

    # 2. Or permit the root account to have ssh access
    cp -Rf "/usr/jails/flavors/finch-ssh-root/etc/ssh" "/usr/jails/${jailname}/etc/"

    # Edit the jail's rc.conf file to enable the ssh daemon
    sysrc -f "/usr/jails/${jailname}/etc/rc.conf" "sshd_enable=YES"

    # Make sure you have created your chosen ssh login accounts.
    # You must also set a password as per the previous the example(s) above ^^

    # Restart the jail - to start the ssh daemon
    qjail restart "$jailname"

    # Test the connection - ssh into the jail
    username="root" # put again your chosen username
    ssh "${username}@${jail_ip}"
