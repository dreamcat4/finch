# VirtualBox

[cf]:http://www.commandlinefu.com/commands/view/188/copy-your-ssh-public-key-to-a-server-from-a-machine-that-doesnt-have-ssh-copy-id

[[ toc ]]

## Install

Finch does not come bundles with VirtualBox preinstalled for you. As not everybody wants / needs it. But for those who do, there are two different ways to get it.

VirtualBox can be installed with pkg-ng by typing:

    ASSUME_ALWAYS_YES="yes" pkg install virtualbox-ose

However the precompiled pkg also requires QT4 and X11 dependancies. If you are running as server the alternative is to build VirtualBox from the ports tree with custom options that exclude those dependancies^1. For example, this command:

date
df -m
cd /usr/ports/emulators/virtualbox-ose && make "BATCH=yes" "WITH=GUESTADDITIONS VDE VPX VIMAGE" "WITHOUT=NLS QT4 X11" install clean
df -m
date

Will build VirtualBox with the following options:

    ┌─────────────────────────── virtualbox-ose-4.3.8 ─────────────────────────────┐
    │ ┌──────────────────────────────────────────────────────────────────────────┐ │  
    │ │+[x] DBUS            D-Bus IPC system support                             │ │  
    │ │+[ ] DEBUG           Debug symbols, additional logs and assertions        │ │  
    │ │+[x] GUESTADDITIONS  Build with Guest Additions                           │ │  
    │ │+[x] NLS             Native Language Support                              │ │  
    │ │+[ ] PULSEAUDIO      PulseAudio sound server support                      │ │  
    │ │+[x] PYTHON          Python bindings or support                           │ │  
    │ │+[ ] QT4             Build with QT4 Frontend                              │ │  
    │ │+[x] UDPTUNNEL       Build with UDP tunnel support                        │ │  
    │ │+[x] VDE             Build with VDE support                               │ │  
    │ │+[x] VNC             Build with VNC support                               │ │  
    │ │+[x] VPX             Use vpx for video capturing                          │ │  
    │ │+[x] WEBSERVICE      Build Webservice                                     │ │  
    │ │+[ ] X11             X11 (graphics) support                               │ │  
    │ └──────────────────────────────────────────────────────────────────────────┘ │  
    ├──────────────────────────────────────────────────────────────────────────────┤  
    │                       <  OK  >            <Cancel>                           │  
    └──────────────────────────────────────────────────────────────────────────────┘  

    ┌─────────────────────── virtualbox-ose-kmod-4.3.8_1 ──────────────────────────┐
    │ ┌──────────────────────────────────────────────────────────────────────────┐ │  
    │ │+[ ] DEBUG   Debug symbols, additional logs and assertions                │ │  
    │ │+[x] VIMAGE  VIMAGE virtual networking support                            │ │  
    │ └──────────────────────────────────────────────────────────────────────────┘ │  
    ├──────────────────────────────────────────────────────────────────────────────┤  
    │                       <  OK  >            <Cancel>                           │  
    └──────────────────────────────────────────────────────────────────────────────┘  


Alternatively, port options may be selected interactively with `make config`. See the ports manpage (`man ports`) for other useful commands, for example:

cd /usr/ports/emulators/virtualbox-ose && make "BATCH=yes" "WITH=GUESTADDITIONS VDE VPX VIMAGE" "WITHOUT=NLS QT4 X11" showconfig[-recursive]

Is especially useful to double-check your intended selections before build time.

^1 Without `QT4` will also mean no Native Language Support (NLS), possibly worse for non-English speakers. Bearing in mind that it only matters if NLS language option is affected to the cli also. Usually such associated command-line utilities come in English regardless.

**Note:** During tests we found that method a took w time and x megabytes of disk space. Wheras method b took y time and z megabytes of disk space.


## Usage

## VirtualBox in it's own Jail

If you don't intend to use FreeBSD jails (only VirtualBox), then putting VirtualBox inside it's own jail may not be what you prefer. Mainly because there are a few extra steps required to setup disk shares for your data and VMs. And the extra command needed (`sudo qjail console virtualbox`) to get console access. Another drawback of putting VirtualBox in a jail is the access to host networking features required for shared interface, NAT, and bridging.

On the flip side, a jail allows VirtualBox to be protected in it's own sandbox. Protecting the host system in the event that one of your VMs is compromised. A jail also means that when VirtualBox has VNC and it's Webservice running, there is no risk of any conflict with existing services that may be running on the host system.


It's really only a matter of personal preference.


