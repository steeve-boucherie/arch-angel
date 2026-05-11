# arch-angel 👼

> A growing collection of small Bash utilities for Arch Linux — because life's too short for repetitive commands.

> ⚠️ **Work in progress.** New scripts will be added over time as needs arise.

---

## Scripts

| Script | Description |
|---|---|
| `update-mirrors` | Updates the pacman mirror list for faster and more reliable package downloads |
| `backup-phone` | Automatically backs up an Android phone over USB |

---

## Installation

### Requirements

- Arch Linux
- `make`
- `sudo` privileges

### Install

Clone the repo and run `make install`:

```bash
git clone https://github.com/yourusername/arch-angel.git
cd arch-angel
make install
```

Scripts are **symlinked** into `/usr/local/bin`, meaning any update pulled via `git pull` is immediately reflected — no reinstall needed.

### Uninstall

```bash
make uninstall
```

---

## Updating

Since scripts are symlinked, updating is just:

```bash
git pull
```

That's it.

---

## Adding a new script

1. Drop your script under `scripts/`, e.g. `scripts/my-util.sh`
2. Make sure it has a shebang line (`#!/usr/bin/env bash`)
3. Run `make install` once to create the symlink
4. Future updates via `git pull` are picked up automatically

---

## License

MIT
