# fapple

Make `~/Library/Trial` **unwritable to Apple’s `triald`**.

That is the whole product. `triald` is a per-user LaunchAgent (`/usr/libexec/triald`) that writes CloudKit experiment files into `~/Library/Trial`. There is no official off switch. `fapple` exists to make that path unusable for it.

`triald` can still *run*; it just cannot store anything in `~/Library/Trial`.

## Why a full disk is not enough

A 1 MB volume filled with `filler.binary` looks blocked (`No space left on device`), but it is **not**. `triald` runs as you, so it can delete `filler.binary` and then write. A normal `unlink` clears the filler and the volume goes back to having free space.

The mount must be **read-only**. Then `triald` gets `Read-only file system` for both creates and deletes.

## What it does

1. Reuses the existing 1 MB image if one is already there (never 1 GB)
2. Empties that user’s `~/Library/Trial` host folder
3. Covers `~/Library/Trial` with that image **mounted read-only**
4. Probes a write and fails if `triald` would still succeed
5. Remounts read-only at login (`local.fapple`)

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

Write probes that must fail:

```bash
touch ~/Library/Trial/triald-test
# touch: ~/Library/Trial/triald-test: Read-only file system

rm ~/Library/Trial/filler.binary
# rm: ~/Library/Trial/filler.binary: Read-only file system

fapple status
# writes:       blocked (triald cannot write)
```

## Related

Companion to [Puck Apple Trials](https://github.com/markrowsoft/Fuck_Apple_Trials), which notifies you when Trial files appear.

## License

MIT
