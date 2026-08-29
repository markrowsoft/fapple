# fapple

Occupy `~/Library/Trial` with a **1 MB** disk so Apple’s `triald` has nowhere to write.

The volume is **1 megabyte**, not 1 GB. It is **filled to 100% on purpose**. Writes failing with `No space left on device` is the point, not a bug.

## What it does

Apple’s Trial system (managed by `triald`) drops CloudKit experiment data in `~/Library/Trial`. `fapple` attaches a tiny HFS+ disk image at that path so the directory is a mount point instead of a writable folder on the boot volume, then fills the image until it is full.

If the 1 MB disk **already exists**, `fapple` does not recreate it (that would un-break it). It:

1. Unmounts the disk if it is attached somewhere else
2. Makes sure that user’s `~/Library/Trial` directory is empty
3. Remounts the same already-full disk there

Each user with sudo can point the same small disk at **their** `~/Library/Trial`.

## Install

```bash
sudo make install
# or
sudo ./fapple install
```

That copies `fapple` to `/usr/local/bin/fapple` so any user on the Mac can run it (sudo required for create / physical partitions).

## Usage

```bash
sudo fapple                 # create the 1 MB disk if needed, empty ~/Library/Trial, remount
sudo fapple mount           # empty ~/Library/Trial and remount the existing 1 MB disk
sudo fapple unmount
sudo fapple status
sudo fapple destroy
fapple enable-auto-mount    # remount at login for this user
fapple disable-auto-mount
```

Default mount point is the calling user’s `~/Library/Trial` (the sudoer’s home when run via `sudo`). Override with `--mount-point`.

## Why 1 MB, not 1 GB

A 1 GB (or even an empty 1 MB) disk would give `triald` room to write. The image is tiny and then stuffed with `filler.binary` until capacity is 100%. That is broken on purpose. `fapple` will refuse any size other than 1 MB.

Internal APFS boot disks usually have no spare GPT room, so the default is a disk image rather than a real partition. Pass `--partition DISK` only when you have free space on an external disk.

## Related

Companion to [Puck Apple Trials](https://github.com/markrowsoft/Fuck_Apple_Trials), which notifies you when Trial files appear.

## License

MIT
