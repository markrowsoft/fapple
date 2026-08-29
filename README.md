# fapple

Make `~/Library/Trial` **unwritable to Apple’s `triald`**.

The volume is **1 MB on purpose**, not 1 GB, so it is easy to fill. That tiny disk is **broken on purpose**: once `filler.binary` occupies every free byte, `triald` gets `No space left on device` and cannot store experiment data.

`triald` is a per-user LaunchAgent (`/usr/libexec/triald`) that writes CloudKit experiment files into `~/Library/Trial`. There is no official off switch. `fapple` covers that path with the 1 MB image, fills it, and keeps it mounted at `~/Library/Trial`.

`triald` can still *run*; it just cannot store anything in `~/Library/Trial`.

## Why 1 MB

A 1 GB (or even an empty 1 MB) disk would give `triald` room to write. One megabyte fills in a moment. `fapple` will refuse any other size.

The image is also mounted **read-only** so `triald` cannot delete `filler.binary` and free space again.

## What it does

1. Reuses the existing 1 MB image if one is already there (never 1 GB)
2. Empties that user’s `~/Library/Trial` host folder
3. Mounts the image at `~/Library/Trial`, fills it if needed, then remounts **read-only**
4. Probes a write and fails if `triald` would still succeed
5. Remounts at login (`local.fapple`)

## Install

```bash
sudo make install
# or
sudo ./fapple install
```

Copies `fapple` to `/usr/local/bin/fapple`.

## Usage

```bash
sudo fapple                 # create 1 MB disk if needed, fill it, remount read-only
sudo fapple mount           # empty Trial and remount the existing 1 MB disk
fapple status               # must say writes: blocked
fapple enable-auto-mount    # remount at login
fapple disable-auto-mount
sudo fapple unmount
sudo fapple destroy
```

Default mount point is the calling user’s `~/Library/Trial`.

Success looks like:

```
writes:       blocked (triald cannot write)
mount flags:  read-only
```

Write probes that must fail:

```bash
touch ~/Library/Trial/triald-test
# Read-only file system  (or No space left on device)

rm ~/Library/Trial/filler.binary
# Read-only file system

fapple status
# writes:       blocked (triald cannot write)
```

## Related

Companion to [Puck Apple Trials](https://github.com/markrowsoft/Fuck_Apple_Trials), which notifies you when Trial files appear.

## License

MIT
