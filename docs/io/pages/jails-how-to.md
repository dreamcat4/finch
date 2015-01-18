# Jails - How To

*For* ***[FreeNAS][fn]***, ***[NAS4Free][n4f]*** *and* ***[pfSense][pf]***.

[jip]:/finch/jails-ip-addresses
[if]:/finch/install
[qjr]:/finch/qjail-reference
[mf]:/finch/mounting-filesystems
[js]:/finch/jails-ssh
[fn]:http://www.freenas.org/
[n4f]:http://www.nas4free.org/
[pf]:https://www.pfsense.org/

[[ toc ]]

## Pre-requisites

* FreeNAS, NAS4Free and pfSense users must first **[Install Finch][if]**.
* **[Reserve an IP address][jip]** for your new jail.
* Decide whether you need **[ssh access][js]** for this jail.

## Create a new jail

    # Enter the finch chroot environment, as root
    sudo finch chroot

    # Read the page "jail-ip-addresses" before choosing a jail IP address
    jail_ip="192.168.1.201"

    # Set a matching ip address for the jail's 'lo0' ifconfig device (for localhost)
    jail_loopback="lo0|127.0.0.201"

    # Give an appropriate server name to your jail
    jailname="nginx"

    # Create a basic jail, with local console access
    qjail create -4 "$jail_ip,$jail_loopback" "$jailname"

    # Enable unix sockets
    qjail config -k "$jailname"

## Login for the first time

    # Start the jail
    qjail start "$jailname"

    # Login to our new jail as root
    qjail console "$jailname"

    # (optional) set the root password
    passwd

## Example: Install a webserver

    # Update local pkgng database, to avoid 'failed checksum' for 'pkg install'
    pkg update -f

    # Either a) install with pkg-ng
    ASSUME_ALWAYS_YES="yes" pkg install "nginx"    

    # Or b) compile from the ports tree
    cd "/usr/ports/www/nginx" && make "config-recursive" "install" "clean"

    # Enable nginx rc.d service inside the jail
    sysrc "nginx_enable=YES"

    # Exit from the jail
    exit

    # Restart the nginx jail - should start the nginx rc.d script
    qjail restart "$jailname"
    
    # Check that nginx is running
    fetch -o - "http://$jail_ip" # or open "http://$jail_ip" in a web brower

## What next ?

* Learn how to mount user data into your jails with **[Mounting filesystems][mf]**.
* Read the **[Jails ssh How To][js]** to create a jail with ssh access.
* Consult the **[Qjail reference][qjr]** page for more jail configuration options.
