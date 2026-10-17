mo clean         # Deep cleanup

# VM disk cleanup

`bin/disk-cleanup` is the janitor for exe.dev VMs. It is scheduled from cron
and logs to `~/.local/state/disk-cleanup.log`.

```sh
disk-cleanup                 # hourly (minute 7): /tmp scratch >48h, go-build,
                             #   npm cache, stale node_modules, docker, journald
disk-cleanup --deep          # daily (04:30): adds gradle caches, android/JS
                             #   build output, npx cache, old browser
                             #   revisions, unused rust toolchains, AVD userdata
disk-cleanup --report        # what is filling the disk right now (read-only)
disk-cleanup --deep --dry-run # what the next deep pass would delete
```

Every deletion is gated on "untouched for N days" plus "no process has the
path open and no process has its cwd inside it". It never touches source files,
toolchains (node, rustup, android-sdk), node_modules that are still in use,
volta/npm installs, or AVD definitions.

When the disk still fills up, `--report` names the top consumers. The usual
suspects on this VM: `~/Code/*/node_modules`, android `app/build` output,
`~/.android/avd/*/userdata-qemu.img.qcow2`, and agent scratch dirs in `/tmp`.
