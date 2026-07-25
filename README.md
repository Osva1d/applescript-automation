# AppleScript Automation for macOS Print Production

[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

> Three macOS AppleScript automations that remove repetitive steps from a print
> production workflow — mounting volumes, creating project folders, and formatting
> Adobe Bridge headers. Each runs as a Shortcuts.app shortcut, triggered by a keypress.

**Language:** English · [Čeština](README.cs.md)

This repository holds **three independent scripts**. Each has its own README and
changelog — this page is a signpost.

---

## What's inside

| Script | What it does | Docs |
|--------|--------------|------|
| **start-finder** | Waits for the network, mounts all shared volumes, and opens Finder with preset folder tabs in list view | [README](start-finder/README.md) · [CHANGELOG](start-finder/CHANGELOG.md) |
| **create-project-folders** | Reads order data from the active Safari tab and creates a standardized project folder hierarchy (`orderNumber - client - project`) on a shared volume | [README](create-project-folders/README.md) · [CHANGELOG](create-project-folders/CHANGELOG.md) |
| **generate-bridge-header** | Builds a fixed-width (85 char) Adobe Bridge header from order data, copies it to the clipboard, and opens the matching production folder in Bridge | [README](generate-bridge-header/README.md) · [CHANGELOG](generate-bridge-header/CHANGELOG.md) |

### Why they exist

- **start-finder** — after every macOS login, network volumes have to be mounted by hand and Finder opened on specific folders. The script does the whole sequence unattended.
- **create-project-folders** — a print studio handling 8–15 new orders a week needs a folder per order with a strict naming convention. Manually that means switching between browser and Finder, copying text, and double-checking names.
- **generate-bridge-header** — every job needs a Bridge header with client name, print technology, and order number, aligned to exactly 85 characters (left / center / right). Composing that by hand with spaces means counting characters and getting it wrong. At 20–40 operations a week it adds up.

---

## Shared conventions

- **Runs from Shortcuts.app** — each script is pasted into a "Run AppleScript" action and triggered by a keyboard shortcut or a login item. No installer, no build step.
- **Configuration lives in the script** — a clearly marked `KONFIGURACE` block at the top holds the values you must change (server, volumes, paths). There is no external config file: since installation is a copy-paste of the source, your copy is private from the start.
- **`CONFIG_DONE` guard** — every script starts with `property CONFIG_DONE : false` and refuses to run until you set it to `true`. It prevents a first run against the placeholder values with a confusing "volume not available" error.
- **Czech user interface** — dialogs and notifications are in Czech; code comments are in English.
- **Defensive by default** — `try / on error` around every external boundary, `quoted form of` on every shell path, volume availability checked before any file operation.

---

## Requirements

- **OS:** macOS 13+ (Ventura or newer)
- **Shortcuts.app** — the scripts are dispatched from it
- **Safari with "Allow JavaScript from Apple Events"** — for the two scripts that read order data from a web page
- **Adobe Bridge** — for `generate-bridge-header` only
- **Accessibility permission** — for `start-finder` (it creates Finder tabs via keystrokes)

---

## Getting started

There is nothing to download or build — the source *is* the deliverable:

1. Open the script's `.applescript` file in this repository and copy its contents.
2. In Shortcuts.app, create a new shortcut and add a **Run AppleScript** action; paste the source in.
3. Edit the `KONFIGURACE` block at the top: replace the placeholder values (server, volumes, paths) with your own.
4. Set `property CONFIG_DONE : true`.
5. Assign a keyboard shortcut, or add the shortcut to your login items.

Per-script details (configuration table, usage, troubleshooting) are in each
script's README, linked in the table above.

> **Note on placeholder values.** The paths and hostnames in the repository
> (`fileserver.local`, `/Volumes/PrintServer/…`) are neutral examples, not a real
> environment. Replace them with yours.

---

## License

MIT License. Copyright (C) 2025–2026 Ladislav Osvald. See [`LICENSE`](LICENSE).

Free to use, copy, modify, and distribute (including commercially), provided the
copyright notice is kept. Provided "as is", without warranty of any kind.

---

## Author

Ladislav Osvald (Osva1d), 2025–2026.
