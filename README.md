# fapple

Make Apple Trial directories **unwritable to `triald` / `triald_system`**.

The volume is **1 MB on purpose**, not 1 GB, so it is easy to fill. That tiny disk is **broken on purpose**: once `filler.binary` occupies every free byte, writes fail with `No space left on device`. The image is then mounted **read-only** so the daemon cannot delete the filler and free space again.

Apple runs two jobs. Neither can be lastingly disabled (SIP + XPC restart them):

| Process | Writes to |
|---|---|
| `/usr/libexec/triald` (LaunchAgent) | `~/Library/Trial` |
| `/usr/libexec/triald_system` (LaunchDaemon) | `/Library/Trial` |

`fapple` occupies **both** (system path needs sudo). It does **not** try to stop the daemons. It deletes files that are not open, then attaches the 1 MB disk before they recreate anything. Open files are skipped until the holder drops the FD; if they remain, `triald` is signaled only so FDs drop — it will restart onto the read-only mount.

The daemons can still *run*; they just cannot store experiment data.

## What it does

1. Reuses each existing 1 MB image (never 1 GB)
2. Deletes unopened files under `~/Library/Trial` and `/Library/Trial`
3. Mounts a 1 MB image **read-only** at each path
4. Probes a write and fails if Trial would still be writable
5. Remounts `~/Library/Trial` at login and `/Library/Trial` at boot

## Install

```bash
sudo make install
# or
sudo fapple install
```

Copies `fapple` to `/usr/local/bin/fapple`, occupies both Trial dirs, and enables auto-mount.

## Usage

```bash
sudo fapple                 # occupy ~/Library/Trial and /Library/Trial
sudo fapple mount           # same: empty unopened files, remount read-only
fapple status               # both paths must say writes: blocked
sudo fapple unmount
sudo fapple destroy
```

Success:

```
user triald (~/Library/Trial):
  writes:       blocked
  mount flags:  read-only

triald_system (/Library/Trial):
  writes:       blocked
  mount flags:  read-only
```

## Related

Companion to [Puck Apple Trials](https://github.com/markrowsoft/Fuck_Apple_Trials).

## License

MIT
