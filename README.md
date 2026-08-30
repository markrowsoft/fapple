# fapple

Make Apple Trial directories **unwritable to `triald` / `triald_system`**.

The volume is **1 MB on purpose**, not 1 GB, so it is easy to fill. That tiny disk is **broken on purpose**: once `filler.binary` occupies every free byte, writes fail with `No space left on device`. The image is then mounted **read-only** so the daemon cannot delete the filler and free space again.

Apple runs two jobs. Neither can be lastingly disabled (SIP + XPC restart them):

| Process | Writes to |
|---|---|
| `/usr/libexec/triald` (LaunchAgent) | `~/Library/Trial` |
| `/usr/libexec/triald_system` (LaunchDaemon) | `/Library/Trial` |

`fapple` occupies **both** (system path needs sudo). It does **not** try to disable the daemons (SIP + XPC would restart them). It kills processes that have files open under `~/Library/Trial` and `/Library/Trial`, removes those files, then attaches the 1 MB disk before the daemons recreate anything. `triald` / `triald_system` restart onto the read-only mount.

The daemons can still *run*; they just cannot store experiment data.

## What it does

1. Reuses each existing 1 MB image (never 1 GB)
2. Kills processes holding files under `~/Library/Trial` and `/Library/Trial`, then deletes those files
3. Mounts a 1 MB image **read-only** at each path
4. Probes a write and fails if Trial would still be writable
5. Remounts `~/Library/Trial` at login and `/Library/Trial` at boot

## Install

```bash
sudo make install
# or, to unmount, replace the binary, and occupy both Trial dirs again:
sudo make reinstall
# or
sudo fapple install
```

Copies `fapple` to `/usr/local/bin/fapple`, occupies both Trial dirs, and enables auto-mount.

`sudo fapple install` occupies **both** Trial dirs and enables login + boot auto-mount, even if `/usr/local/bin/fapple` is already present. Without sudo it can only occupy `~/Library/Trial` and the login agent.

If `df` or Finder shows `~/Library/Trial` or `/Library/Trial` as terabytes, the 1 MB image is **not mounted** and `triald` is writing to the host disk. `fapple status` must say `volume size: 1048576 bytes` and `1 MB image: yes` for both paths.

## Test after logout

```bash
sudo fapple install
fapple status
```

Both `~/Library/Trial` and `/Library/Trial` should show `writes: blocked`, `mount flags: read-only`, and `1 MB image: yes`.

Then log out and back in (reboot if you also want the boot job for `/Library/Trial`). After login:

```bash
make test
# or:
fapple status
touch ~/Library/Trial/x          # should fail: Read-only file system
sudo touch /Library/Trial/x      # should fail: Read-only file system
```

`make test` runs `fapple status` and those write probes; it fails if either path is writable.

`local.fapple` remounts the user path at login. `local.fapple.system` remounts `/Library/Trial` at boot.

## Usage

```bash
sudo fapple                 # occupy ~/Library/Trial and /Library/Trial
sudo fapple mount           # same: kill holders, empty Trial dirs, remount read-only
fapple status               # both paths must say writes: blocked
sudo fapple unmount
sudo fapple destroy
```

Success:

```
user triald (~/Library/Trial):
  volume size:  1048576 bytes
  1 MB image:   yes
  writes:       blocked
  mount flags:  read-only

triald_system (/Library/Trial):
  volume size:  1048576 bytes
  1 MB image:   yes
  writes:       blocked
  mount flags:  read-only
```

## Related

Companion to [Puck Apple Trials](https://github.com/markrowsoft/Fuck_Apple_Trials).

## License

MIT
