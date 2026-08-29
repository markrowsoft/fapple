# fapple

Make `~/Library/Trial` **unwritable to Apple’s `triald`**.

`triald` (a per-user LaunchAgent at `/usr/libexec/triald`) stores CloudKit experiment data in `~/Library/Trial`. There is no official off switch. `fapple` covers that path with a 1 MB disk **mounted read-only**, so `triald` gets `Read-only file system` and cannot store files.

A full-but-read-write volume is **not** enough. `triald` can delete `filler.binary` and then write. The mount must be read-only.

## What it does

1. Reuses the existing 1 MB image if one is already there (never 1 GB)
2. Empties that user’s `~/Library/Trial` host folder
3. Mounts the image **read-only** at `~/Library/Trial`
4. Probes a write and fails if `triald` would still succeed

If the image file is writable (first-time setup as root), `fapple` also fills it, then `chmod a-w` / `chflags uchg` the `.dmg` so later user attaches stay read-only.

## Install

```bash
sudo make install
# or
sudo ./fapple install
```

Copies `fapple` to `/usr/local/bin/fapple`.

## Usage

```bash
sudo fapple                 # create 1 MB disk if needed, empty Trial, remount read-only
sudo fapple mount           # empty Trial and remount the existing disk read-only
fapple status               # must say writes: blocked
fapple enable-auto-mount    # remount read-only at login
fapple disable-auto-mount
sudo fapple unmount         # unmount, then chmod 000 the host folder
sudo fapple destroy
```

Default mount point is the calling user’s `~/Library/Trial`.

Success looks like:

```
writes:       blocked (triald cannot write)
mount flags:  read-only
```

## Related

Companion to [Puck Apple Trials](https://github.com/markrowsoft/Fuck_Apple_Trials), which notifies you when Trial files appear.

## License

MIT
