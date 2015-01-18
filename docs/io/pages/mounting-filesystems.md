
# Mounting filesystems

[qjrzj]:/finch/qjail-reference/#toc_4

[[ toc ]]

## The Nullfs restriction

The restriction: *you can't `mount_nullfs` twice in a row !* It's because...

* FreeBSD's implementation of nullfs only ever creates a single-layer overlay. Therefore it is not possible to stack multiple nullfs layers on top of each other.
* In other words, it's not possible to daisy-chain nullfs mounts.
* You will acutally be mounting whatever was previously underneath it (usually an empty directory).
* If you have nullfs mounted some toplevel (global host folder) into finch's chroot, then for example, a jail fstab entry inside finch cannot pick it up.
* The restriction rears it's head because typically we want to mirror some of our data that available on the host system into the Finch subdirectory (by using nullfs). Then in turn from within Finch into our guest jails. Making then a second layer of indirection (which we can't have).

### The Solution

For a trouble-free life, please follow these steps when mounting your user data:

* Unmount your data from it's existing mountpoint on the host system.
* Directly mount your user data into a location inside the Finch chroot. For example:

```
    $finch_realpath/mnt/my_data
    $finch_realpath/usr/jails/sharedfs/my_data
```
* Make a `nullfs` mapping from the new location inside Finch ---> back to outside where the folders previously used to be.
* Add a nullfs entry to your jail's fstab file [as decribed later on][jfstab] to also mapthe data into your jail(s).^1

[jfstab]:#toc_8
[jsfs]:#toc_9

You should end up with:

    HOST (nullfs mappings) <---- FINCH (your data is mounted here) ----> JAILS (nullfs mappings)

It might seem a little odd, but the best place to mount your user data folders is somewhere inside the Finch chroot. Being located in the middle means that it can be seen from either side of the fence.

^1 Not necessary for mounts within `usr/jails/sharedfs`, which is automatically mounted into *all jails*. More information [here][jsfs].

# Example

## Zfs

In this following example, we show you how to mount or remount zfs partitions (a.k.a. "datasets"). All of our datasets are on one single zfs pool, shown here as `disk0`, and with no altroot setting (`altroot='/'`).

### Existing dataset

Let us suppose we already have an existing dataset, named `my_dataset`. OR we can find out a dataset's name and current mountpoint with the `zfs list` command:

    $ zfs list
    NAME                                      USED  AVAIL  REFER  MOUNTPOINT
    disk0                                    68.9G   616G  67.1G  /mnt/disk0
    disk0/my_dataset                          144K   616G   144K  /mnt/disk0/my_dataset

If we have:

    finch_realpath="/mnt/disk0/finch" # <---- our finch chroot
    zfspool="disk0"                   # <---- our zfs pool
    dataset="disk0/my_dataset"        # <---- our zfs dataset

Firstly, make sure you are *outside* of the finch chroot. Then get your `/path/to/finch` with this command:

    finch_realpath="$(finch realpath)"

We can move our dataset's mountpoint to be inside of our Finch chroot:

    zfs set mountpoint="${finch_realpath}/mnt/disk0/my_dataset" "$dataset"

We can also put back (replace) the previous mountpoint so it's the same as before:

    mkdir -p /mnt/disk0/my_dataset
    mount_nullfs "${finch_realpath}/mnt/disk0/my_dataset" "/mnt/disk0/my_dataset" 

### New dataset

For a new dataset, we do almost exactly the same as "existing dataset" situation above. Except for this part:

    dataset="disk0/new_dataset"
    zfs create "$dataset"
    zfs set mountpoint="${finch_realpath}/mnt/${dataset}" "$dataset"


### Jail - fstab

Now we can add the dataset to our jail's fstab file

    jailname="my_jail"   # <---- The name of our jail

    # Stop the jail
    finch qjail stop "$jailname"

    # Create an emtpy folder where we will nullfs mount our data
    mkdir -p "${finch_realpath}/usr/jails/${jailname}/mnt/${dataset}"

    # Edit the jail's fstab file in a text editor...
    nano "${finch_realpath}/usr/local/etc/qjail.fstab/${jailname}"

    # ...and add the following line (not the >>> arrows!)
    >>>
    /mnt/$dataset /usr/jails/my_jail/mnt/$dataset nullfs ro 0 0
    >>>

    # Start the jail
    finch qjail start "$jailname"
    
    # Check that it mounted
    df

### Jail - sharedfs mount

Qjail mounts one special folder, sharedfs as read-only inside all of your jails. So if you wish you may create additional folder(s) inside the directory /usr/jails/sharedfs and that user data can be seen (read-only) inside all of your jails.

So what if you have a data partition which you want to share amongst ALL of your jails?

Unfortunately it is the case that mount_nullfs does not traverse filesystem boundaries and therefore you cannot place mounts inside the sharedfs folder and see them from inside the jail's perspective. The folders do not remap. So you will need to create individual fstab entries for each folder, in each jail's fstab file where you wish to mount them. (as per the previous section).

## Non-zfs

Let us suppose you have a FAT32, NTFS, or EXT (linux) data partition. Follow the above ZFS steps. But don't issue any zfs commands. Whenever you hit a zfs command *perform an equivalent step*. Use the same paths / locations as in the zfs guide.

* In FreeNAS and FreeBSD-GENERIC, edit the global `/etc/fstab`.
* In NAS4Free, navigate to `Disks | Mount Point | Management` in the Web GUI.

## Finch's fstab

Finch does also have it's own `fstab` file should you feel inclined to use it. However it is not usually necessary since your host system already has it's own fstab file or equivalent mechanism.

* Located at `$finch_realpath/etc/fstab`.
* Works just the same as your host's `/etc/fstab` file.
* Mounts can be from and disks or folders available on the host system. Toplevel / global scope.
* Fstab entries will be mounted just before `finch start` and unmounted after `finch stop`.


    