# Changelog

All notable changes to Voice Commands, newest first. Fixes name the cause and the solution, so that a
problem that comes back can be traced to how it was solved before.

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
