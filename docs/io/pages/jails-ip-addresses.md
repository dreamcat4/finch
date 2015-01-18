# Jails - IP Addresses

Each time a jail is started, FreeBSD's jail(8) utility will tell ifconfig to create a simple alias to your jail's designated ip address. However that only occurs on the FreeBSD host machine. In most situations, your local network is under the control of a local router. So to prevent ip address conflicts elsewhere you should reserve your jail's ip address on your local router too.

## Reservation Strategies

#### 1) Use High-IPs

Most router DHCP servers usually allocate ips in ascending order. So one strategy is simply give jails a high-enough ip addresses that they will not be likely to cause conflicts.

* For example: start your jails at "192.168.1.100", or "192.168.1.200" etc.
* Not the most flexible / efficient way to allocate IP addresses. There may be some wastage.
* Be aware that the highest IP address is going to be about "192.168.1.255"

#### 2) Alter the DHCP range

Optionally, you may also decide restrict your home router's DHCP allocation range. The requires going into your router's DHCP settings and changing the first / last IP address.

* A DHCP range of "192.168.1.2" --> "192.168.1.100" will not conflict with jails that start at ".101".
* Or you could make the DHCP start at a higher IP, leaving the lower IP range available for jails.
* Still not the most flexible / efficient way to allocate IP addresses. There may be some wastage.

#### 3) Static DHCP - Multi-IP

This option depends entirely on your router's capabilities. Unfortunately for most home routers it's not possible to assign multiple static IPs to the a single mac address. Normally only 1 IP can be assigned to each MAC address and no more. However if your specific router supports it, then by all means use this method.

* With static DHCP you can assign *any arbitrary IP address* within the same mixed DHCP range.
* The same DHCP server is then aware of your jail's IP address and won't assign it to any other devices.
* Feature usually not capable of assigning multiple IPs to only 1 MAC address.

#### 4) Static DHCP - fake MAC address

If your router does not support method 3), you may still be able to use Static DHCP. Just create your "static DHCP" entries with FAKE mac addresses.

* Be sure that the MAC addresses you choose are not real, and do not exist on your LAN.
* Locally administered MAC addresses should start with the byte `0x02:`.
* Protects the jail IP address(es) from being grabbed away by the regular DHCP pool.
