# Qjail Reference

[fs]:/finch/support
[mf]:/finch/mounting-filesystems

[[ toc ]]

## Basic commands

    # Creating, modifying and deleting jails
    qjail [create|config|delete] <options> "$jailname"

    # Starting / stopping jails
    qjail [start|stop|restart] "$jailname"

    # Login to a jail (as root)
    qjail console "$jailname"

    # Report the current status of all jails
    qjail list

    # Display a jail's configuration settings
    qjail config -d "$jailname"

    # (re-)clone the /usr/ports tree into /usr/jails/sharedfs
    qjail update -P

    # Update the /usr/jails/sharedfs ports tree
    qjail update -p

    # Update FreeBSD binaries & libs (all jails)
    qjail update -b

    # Rename a jail
    qjail config -n "$new_jailname" "$old_jailname"

## Config

### Manual mode

    # Disable auto-starting of the jail during system boot
    qjail config -m "$jailname"

    # Enable auto-starting of the jail during system boot
    qjail config -K "$jailname"

### Enable unix sockets

    # Enable unix sockets
    qjail config -k "$jailname"

    # Disable unix sockets
    qjail config -K "$jailname"

### Enable custom devfs_ruleset

    # Enable custom devfs_ruleset
    devfs_ruleset="20"
    qjail config -B "$devfs_ruleset" "$jailname"

    # Disable custom devfs_ruleset
    qjail config -B "$jailname"

### Enable sysvipc semaphores

    # Enable sysvipc semaphores
    qjail config -y "$jailname"

    # Disable sysvipc semaphores
    qjail config -Y "$jailname"

## Disk

### Permit nullfs mounts whilst inside a jail

This feature is disabled by default. It enables the `mount_nullfs` command whilst inside the jail. This feature is not required for any nullfs entries in the jail's fstab file.

    qjail config -l "$jailname"

### Permit zfs mounts whilst inside a jail

This feature is disabled by default.

    qjail config -x "$jailname"

Enabling it allows you to use the command `zfs jail` whilst inside a jail. However we do not recommended this method for mounting your datasets because of the following restrictions:

* Using this feature will allows you to create or mount a zfs dataset into one specific jail.
* This method cannot be used to mount the same zfs dataset across multiple jails.
* For the duration that a dataset is configured to the jail, it cannot be mounted elsewhere.
* The mounted dataset will also be accessible from the host machine (and inside Finch's chroot).
* However when the jail is stopped, the zfs dataset will be automatically unmounted, becoming unavailable in the host environment until the jail is restarted.

To avoid the above restrictions, use our **[Finch-prescribed method][mf]** for mounting your datasets.

## Network

### Change a jail's network interface

    new_network_interface="re0"
    qjail config -c "$new_network_interface" "$jailname"

### Change a jail's ip address

    new_ip_address="192.168.1.202"
    new_loopback_address="lo0|127.0.0.202"

    qjail config -4 "$new_ip_address,$new_loopback_address" "$jailname"

## Avoid

### (has issues) Vnet / Vimage

**Advantages:**

* Unwanted open ports of the host system are not duplicated onto the jail's IP address.
* The jail is allocated it's own unique MAC address, which is visible on your local LAN.

**Disadvantages:**

* Each jail takes a lot longer to start / stop - the extra delay soon adds up for many jails.
* The possible network configurations are more difficult to understand.
* There is no working example provided in the qjail documentation.
* Therefore, proper configuration can be tricky.
* `options VIMAGE` must have been compiled into the kernel. Currently that isn't enabled on NASFree.

The main reason we don't recommend Vnet / Vimage jails is that during testing, the feature was not found to work or function correctly. This appears to be because qjail's `qjail.vnet.be` script will auto-create network addresses in the range `10.${jid}.0.XXX` with a subnet `netmask 0xff000000`. If your host machine's gateway route does not happen to also be a `10.0.0.0` style private network, then it will sit on a different subnet and the jail cannot route packets to it. For example:

    $ route change default 192.168.1.1
    route: writing to routing socket: Network is unreachable
    change net default: gateway 192.168.1.1 fib 0: Network is unreachable

However if your host machine does happen to be on a `10.0.0.0` subnet, then you may have much better luck. In which case, Vnet jails may be configured in the following way:

    # Give an appropriate server name to your jail
    jailname="vnet-jail"

    # Create the jail without any ip address
    qjail create "$jailname"

    # Find your default NIC
    default_nic="$(route get default 2> /dev/null | grep -o "interface.*" | cut -d ' ' -f 2)"

    # Enable vnet/vimage in bridge-epair mode
    qjail config -w "$default_nic" "$jailname"
    printf "none\nbe\n" | qjail config -v "$jailname"

    # Enable unix sockets
    qjail config -k "$jailname"

    # Start the jail
    qjail start "$jailname"

    # Check ifconfig settings - look for the bridge and epair devices
    ifconfig
    echo "ifconfig" | qjail console "$jailname"

    # Check network connectivity
    echo "ping -c 1 google.com" | qjail console "$jailname"

Please **[let us know][fs]** if you think anything here is incorrect, or can provide alternative configuration steps to get these Vnet jails working on hosts which are setup to be outside of the `10.0.0.0` subnet. For example on `192.168.1.XXX` machines, etc.

### (useless) Quotas

    # allow.quotas NOT recommended as does not limit total filesystem usage on a per-jail basis.
    # allow.quotas allows you to allocate limits to individual user accounts inside your jails.
    # qjail config -q "$jailname"

Solution: Create a zfs dataset instead, for the jails and assign quota limits per dataset. User mount_nullfs your zfs dataset onto /finch/usr/jails (move the jails folder onto the dataset).

### (doesn't work) cpuset.id

Assigning a jail to specific CPU cores. For example: a quad-core CPU: `cpuset -g | grep -o -e mask.*` should say `mask: 0, 1, 2, 3`

This feature is documented in `man jail`. However it does not work. The error is:

    jail: $jailname: unknown parameter: cpuset.id`

This feature is currently known to be broken in jail(8) and has recently been removed from qjail. It may or may not be fixed again in some undetermined future FreeBSD update (10.1 / 11).

However even if you can successfully use this feature to limit the core count, the outcome isn't a very efficient way to allocate resources. It may be better to use `rctl` instead. Which requires `options racct` and `options rctl` to be compiled into the kernel.
