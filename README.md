
# FreeBSD in a chroot

*For* ***[FreeNAS][fn]***, ***[NAS4Free][n4f]*** *and* ***[pfSense][pf]***.

[fm]:http://dreamcat4.github.io/finch/manpage
[qj]:http://www.freshports.org/sysutils/qjail
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

## Homepage

For more information, please visit the project's homepage at http://dreamcat4.github.io/finch.

## Created by

Dreamcat4, dreamcat4@gmail.com (C 2014). FreeBSD License.

