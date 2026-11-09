# Changelog

All notable changes to Voice Commands, newest first. Fixes name the cause and the solution, so that a
problem that comes back can be traced to how it was solved before.

## 1.14.2 (2026-11-09)

### Changes

- Voice Commands has its own pacman repository, a release of the GitHub repository, so that `sudo pacman -Syu` and update tools such as cachy-update or Shelly get new versions. The README installs from it; building the package yourself still works. The packages are not signed, which the README explains.

## 1.14.1 (2026-11-09)

### Changes

- When the kernel was updated together with the installation, the kernel module `overlay` cannot be loaded until the next start, and `sudo modprobe overlay` fails with `FATAL: Module overlay not found`. Cause: pacman deletes the modules of the old kernel, which keeps running. Solution: the installation and `voice-commands-setup` recognize this case (no folder for the running kernel in `/lib/modules`) and say to restart first; the README says it in the installation steps and the troubleshooting.

## 1.14.0 (2026-11-09)

### Fixes

- Background programs could get other arguments than web addresses without a dialog. Cause: the permission hook checked the words of the command, but braces were allowed, and the shell turns `voice-commands-bg start {blender,--python,x.py}` into `blender --python x.py`. Solution: braces and backslashes in a call of `voice-commands-bg` ask, like other shell characters.
- Cancelling missed a running command when another one had been waiting. Cause: only the newest command was noted in `work.pid`, and the first command deleted that file when it ended, so the next one ran without it. Solution: cancelling stops every command with a phase in the runtime folder's `state`, which the status bar already uses, and only processes of Voice Commands; `work.pid` is gone.
- GNOME Files (`nautilus`) could be started in the background, although file managers are refused. Solution: it is on the list of refused programs. The tests now give each refused program an existing stub, so that only the list can refuse it.
- A command without a dialog could read a file with secrets in the current folder through an option, as in `date -f.env` or `grep --file=.env`. Cause: options without `/` or `~` were not checked. Solution: a value attached to an option is checked for places with secrets too.
- With a home folder whose path has other characters than letters, digits and `/`, such as `/home/john.doe`, conversations of voice commands were never deleted after the chosen days, deleting a response did not delete its conversation, and commands never continued the last conversation. Cause: Claude Code turns every such character into `-` in the name of its folder for the conversations, but `voice-commands` only turned `/` into `-` and looked in a folder that does not exist (the response window already did it right). Solution: `voice-commands` names the folder as Claude Code does, once for all four places.
- Stopping the reading aloud with Piper made the system voice read the whole text again. Cause: the reader caught the stop signal only to delete its sound file and then went on to its fallback, the system voice. Solution: the stop signal ends the reader.
- Background programs could still get other arguments than web addresses without a dialog, through quotes or wildcards. Cause: the arguments were only checked when the second word was exactly `start`, so `voice-commands-bg "start" blender --python x.py` or `st''art` skipped the check, and the shell removes the quotes before running it; wildcards such as `[b]lender` could turn into other words through folder names. Solution: quotes, `*`, `?` and `[` in a call of `voice-commands-bg` ask. A web address with `?` now asks too; zsh refused it without quotes anyway (`no matches found`).
- With zsh's `globdots` or `extendedglob` turned on, a command without a dialog could read files with secrets through a wildcard, as in `cat ~/Documents/*` matching `.env`, or `cat ~/.ss#h/*`. Cause: wildcards were checked with Python's rules, which skip hidden files and do not know `#` and `^`, but Claude Code runs commands in the user's shell with its options. Solution: the check includes hidden files, and `#` and `^` ask like other shell characters.
- Writing the start files of desktop shells in a shared home folder did not ask. Solution: `~/.config/quickshell`, `~/.config/noctalia` and `~/.config/waybar` are protected places, which ask even in a shared folder.
- A broken line in the history, such as `"antwort": null`, kept the response window from opening, and Claude could change the history without a dialog, so a made-up response would have looked like a real one. Solution: the window skips entries whose fields are not text (what a response says is not checked), and the history moved out of the working folder (see Changes).
- Sharing a system folder warned only for exactly `/etc`, `/usr`, `/var`, `/mnt`, `/media` and `/run`, not for `/opt`, `/boot`, `/tmp` or folders below them such as `/etc/NetworkManager`. Solution: every folder outside home warns, except folders on drives below `/mnt`, `/media` and `/run/media`; one function instead of two copies, with tests.
- Cancelling did not stop reading aloud while a voice was still being looked for, which can take seconds, and two quick clicks read two texts at once; meanwhile the response window did not respond. Cause: the reader noted itself only after looking for a voice. Solution: the reader is noted at once and looks for the voice itself; Piper is asked for its options once instead of three times.
- With `XDG_CONFIG_HOME` set, the setup said the desktop was not Hyprland and set no shortcuts. Cause: it looked for `hyprland.lua` in `~/.config/hypr` only. Solution: it looks where Hyprland and `voice-commands-shortcuts` look.
- When a new shortcut was pressed again within 25 seconds, the timer of the earlier capture turned the desktop's shortcuts back on during the later one. Solution: each capture has its own token, and the timer only acts on its own; Hyprland and Plasma use the same timer.
- `packaging/build-package.sh` stopped without a message when `updpkgsums` was missing. Solution: it names the missing program and the package to install.

### Changes

- The language of the windows is found in one place, `voice-commands-theme`, instead of a copy in each window.
- The history of the response window moved from `~/Voice-Commands/antworten.jsonl` to `~/.local/share/voice-commands/antworten.jsonl`, so that neither Claude nor background programs can change it unasked: changing it asks, also in a shared home folder, and background programs only change a copy in memory. The old file is moved on the next command or when the response window opens, unless the new one already exists. A response from a command that was running during the update stays in the old file; a window left open during the update shows an empty list until it is opened again; an older version finds no history.
- The help can be read aloud: a speaker button at the top left of the help; pressing it again or closing the help stops it.
- Piper reads long texts in pieces of a few sentences, each made while the one before it plays, so that reading starts after about a second instead of after the whole text. The system voice gets more time for long texts instead of stopping after 5 minutes.
- The response window asks its helpers about shortcuts and voices only when it opens and after applying settings, not on every change of the list, and no longer fills the list twice when it opens.
- The setup no longer replaces old voices by a separate check; their checksums already do that.

## 1.13.0 (2026-11-09)

First public release, under the MIT License. Tested on fresh Arch Linux installations with Hyprland (Lua settings), KDE Plasma and GNOME.

### Features

- Voice commands for Claude Code: record with a shortcut, speech recognition on your own computer with whisper.cpp and voice detection, a time to cancel (3, 5 or 10 seconds, or off), and a queue for further commands. Commands can also be typed.
- Your own unmodified `claude` runs each command in the working folder `~/Voice-Commands`. A new command continues the last conversation for 5 minutes by default (15, 30 or off), or when you ask to continue. The model can be chosen for voice commands only.
- A permission check of its own decides every step: `~/Voice-Commands` is free, everything else asks in a yes or no dialog (No preselected, Yes after one second, no answer means no). Folders can be shared for good, read only or read and change. Reading commands run without asking within a reach you choose per command, and you can add own commands at your own risk. Places with passwords or keys always ask, and files that can start programs or widen Claude's rights ask before any change, even in shared folders. All permissions can be given for one request after a second warning. Claude gets a current list of its permissions with every command.
- Background programs: Claude can start programs with a launcher entry on an invisible display, look at them in screenshots and operate them. They run in bubblewrap: places with secrets and browser profiles are empty, the home folder is an overlay in memory except `~/Voice-Commands` and folders shared for changing, other processes, the session's D-Bus and the user's own displays are out of reach. Editors, IDEs, file managers and terminals are refused, and starting with anything other than a web address asks. They close after 15 minutes without activity.
- Response window with the last 50 responses, the files Claude made, copying, reading aloud, deleting responses with their conversations, and continuing in Claude Desktop. Settings for reading aloud, spoken language, time to cancel, continuing, shared folders, commands without asking, keeping conversations (1, 7 or 30 days), shortcuts, light or dark look, and a help in German and English.
- Status bar on Hyprland and KDE Plasma, notifications everywhere.
- Keyboard shortcuts set up and changeable on Hyprland (Lua settings), KDE Plasma and GNOME.
- Reading aloud with Piper (AUR package `piper-tts` or `pipx install piper-tts`), otherwise speech-dispatcher or espeak-ng.
- Speech recognition files and voices are loaded from fixed versions and checked with SHA-256.
- Privacy: audio never leaves the computer, screenshots stay in memory, Claude Code's automatic memory is off, and Voice Commands deletes its own conversations from Claude Code's storage after the days set.
- `tests/permission-hook.sh`: 174 tests for the permission check, the command lists and the protected area of background programs.

### Known limitations

- No update notifications; the package is built from this repository, not from the AUR.
- No status bar on GNOME and X11; Hyprland's classic `hyprland.conf` is not supported.
- Continuing in Claude Desktop uses a link Anthropic does not document for Linux.
- Background browsers have none of your logins; Waterfox 6.7.7 draws no web pages on the invisible display.
