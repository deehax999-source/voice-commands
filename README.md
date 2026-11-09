# Voice Commands

Unofficial voice commands for Claude Code on Arch Linux. Press a key, speak an instruction, and Claude Code carries it out on your computer. On request, it operates programs on an invisible background display, so your own screen stays free.

> [!WARNING]
> **This is an AI-generated project built for my personal use.** It was created with Claude Code, and its code has not been independently reviewed or audited. To the extent the law allows, it is shared as is, without warranty or support, and it may stop working or change at any time. Read the [risks](#risks) before installing it, and use it at your own risk.

> [!NOTE]
> **Voice Commands is not affiliated with, endorsed by or sponsored by Anthropic.** Claude and Claude Code are trademarks of Anthropic and are named here only to say what this project works with. Voice Commands does not include Claude Code. It runs your own unmodified installation, signed in with your own account.

## Contents

- [How it works](#how-it-works)
- [Install](#install)
- [Keyboard shortcuts](#keyboard-shortcuts)
- [Using it](#using-it)
- [What Claude may do](#what-claude-may-do)
- [Risks](#risks)
- [Your data](#your-data)
- [Your responsibilities](#your-responsibilities)
- [If something does not work](#if-something-does-not-work)
- [Known limitations](#known-limitations)
- [Update](#update)
- [Uninstall](#uninstall)
- [How it works in detail](#how-it-works-in-detail)
- [Development](#development)
- [License](#license)

## How it works

1. **Recording:** You press the shortcut and speak. The microphone records only from then until you press the shortcut again, for at most 5 minutes. On Hyprland and KDE Plasma, a status bar at the top of the screen shows the recording time; elsewhere a notification does.
2. **Speech recognition:** Your recording is turned into text on your own computer with [whisper.cpp](https://github.com/ggml-org/whisper.cpp). The audio never leaves your computer and is deleted afterwards.
3. **Time to cancel:** A notification shows what was understood. You have 5 seconds by default to cancel it if something was misheard, or you send it right away.
4. **Claude works:** Voice Commands starts your own `claude` in the background with the recognized text, in its own working folder `~/Voice-Commands`. A permission check of its own decides every step Claude wants to take: some need no question, for everything else you get a yes or no dialog (see [What Claude may do](#what-claude-may-do)). Further commands wait in a queue until the current one is done.
5. **Response:** A notification shows the beginning of the response, and the response window keeps it with the files Claude made. On request, the response is read aloud, also on your computer.

Filler words such as "um" are removed from the recognized text, and you can speak freely: if you correct yourself ("no, I mean ..."), the last version counts. If a command is unclear or would have effects that cannot be undone, Claude asks in its response instead of carrying it out.

A new command within 5 minutes of the last one continues the same conversation, so Claude knows what you talked about. You can change this time or turn it off. Saying "continue" or "where we left off" continues the last conversation later as well. If you cannot speak, you can type a command instead (Enter sends, Shift+Enter starts a new line, Esc closes); typed commands start without the time to cancel.

## Install

Before installing, read [What Claude may do](#what-claude-may-do) and the [risks](#risks).

You need:

- an Arch-based system
- Claude Code with a signed-in account
- a microphone, unless you only type commands
- a Wayland desktop for the status bar (see below)

### Supported desktops

| Desktop | Status bar | Keyboard shortcuts | Tested |
|---|---|---|---|
| Hyprland with Lua settings (`hyprland.lua`, Hyprland 0.55 or newer) | yes | set up by `voice-commands-setup`, changed in the settings | yes, on Arch Linux and CachyOS |
| Hyprland with the classic `hyprland.conf` | not supported | not supported | – |
| KDE Plasma (Wayland) | yes | set up by `voice-commands-setup`, changed in the settings | yes, on Arch Linux |
| GNOME (Wayland) | no, only notifications | set up by `voice-commands-setup`, changed in the settings | yes, on Arch Linux |
| Other desktops and X11 | no, only notifications | you add them in your keyboard settings | no |

The status bar needs a Wayland desktop with layer-shell support. On Hyprland, a newer version alone is not enough: Hyprland keeps using an existing `hyprland.conf`, and Voice Commands does not support that format. Move your settings to Lua first, as described in [Hyprland's wiki](https://wiki.hypr.land/configuring/).

### Steps

If Claude Code is not installed yet, install it as described in [Claude Code's setup guide](https://code.claude.com/docs/en/setup), then run `claude` once and sign in.

Build the package from this repository. The first command updates your system and installs the tools needed to build the package. On Arch, always update before installing new packages, otherwise downloads can fail with "failed to retrieve some files".

```bash
sudo pacman -Syu --needed git base-devel pacman-contrib
git clone https://github.com/deehax999-source/voice-commands.git
cd voice-commands
packaging/build-package.sh
cd aur && makepkg -si
voice-commands-setup
```

The package also makes the computer load the kernel module `overlay` at every start (`/usr/lib/modules-load.d/voice-commands.conf`), which the protected area for background programs needs, and loads it right away. `build-package.sh` also writes the checksums of the files into the package description; `packaging/PKGBUILD` in the repository has none on its own, so build with the script, not from that file directly. `makepkg -si` asks for your password and installs the missing dependencies. If pacman asks which of several packages to install, pressing Enter takes the default.

Run `voice-commands-setup` as your normal user, not with `sudo`, in a terminal of your desktop session, so that it can add the shortcuts.

The setup downloads the speech recognition files, and the voices for reading aloud if Piper is installed. On Hyprland, KDE Plasma and GNOME, it also adds the keyboard shortcuts. On other desktops, it shows you the commands to add in your keyboard settings. It also finds Claude Code in `~/.local/bin` when that folder is not in your `PATH`. Anything still missing is listed at the end under "STILL TO DO".

Optional packages: `piper-tts` (AUR, or `pipx install piper-tts`) for a more natural voice, `wl-clipboard` or `xclip` for the copy buttons, `ttf-jetbrains-mono` for the font of the windows, and `claude-desktop` to continue sessions in the desktop app.

## Keyboard shortcuts

| Default key on Hyprland and GNOME | Default key on KDE Plasma | Command for other desktops | Action |
|---|---|---|---|
| `Super+G` | `Meta+H` | `voice-commands toggle` | Start or stop recording |
| `Super+Shift+G` | `Meta+Shift+H` | `voice-commands cancel` | Cancel a recording, a command or reading aloud |
| `Super+Alt+G` | `Meta+Alt+H` | `voice-commands-window` | Open the response window |
| `Super+Ctrl+G` | `Meta+Ctrl+H` | `voice-commands send` | Send the recognized command right away |
| `Super+I` | `Meta+J` | `voice-commands-input` | Type a command instead of speaking |

Plasma has its own defaults because it already uses `Meta+G` and `Meta+I`. On Hyprland, Plasma and GNOME, `voice-commands-setup` adds the shortcuts for you, and you change them in the settings of the response window; all hints show the shortcuts you set. On other desktops, add the commands in your keyboard settings yourself.

## Using it

Notifications, the status bar and the response window appear in German on German systems and in English on all others. Claude replies in the language of your command.

### Response window

It keeps the last 50 responses, newest first, with the time and your command. Long responses show their first three lines and unfold on a click. Each response has buttons to:

- **copy** it with its Markdown marks, so that its structure is kept when you paste it (needs `wl-clipboard` on Wayland or `xclip` on X11)
- **read it aloud**, or stop reading
- **open the files** Claude created or changed for this command: a click opens one with its usual program, a right-click shows it in its folder; programs and scripts are only shown in their folder, never started, and a greyed out file is gone
- **delete** it together with its conversation in Claude Code's storage, with a few seconds to undo; if other responses belong to the same conversation, you choose between deleting the whole conversation and only removing this response from the overview
- **continue it in Claude Desktop** (see below)

The folder button at the top opens `~/Voice-Commands`. The window also appears as **Voice Commands** in your app launcher. To put it on your desktop, if you use one, copy `/usr/share/applications/local.voicecommands.VoiceCommands.desktop` to `~/Desktop`. Some desktops then ask you to allow it to start. The question mark, or F1, opens a help that explains everything in detail, and when the window opens for the first time, a short introduction appears.

### Model

Commands use your default model from Claude Code. To use another model for voice commands only, choose it at the top of the response window. Regular Claude Code sessions stay unchanged. `VOICE_COMMANDS_MODEL` overrides this choice, for example with `sonnet`.

### Settings

The gear button in the response window opens the settings. Changes take effect only when you apply them in the bar at the bottom, or are dropped with Discard; closing the settings with changes left asks first. Tips under "What to watch out for" explain the risks of each choice. There you can:

- turn on reading responses aloud, and choose how much is read and how fast
- set the language you speak, or let it be detected
- set the time to cancel before a spoken command starts (3, 5 or 10 seconds, or off)
- set how long a new command continues the last conversation (5, 15 or 30 minutes, or off)
- share folders with Claude for good, read only or read and change
- choose which reading commands run without asking, and how far each reaches
- set how long conversations are kept in Claude Code's storage (1, 7 or 30 days)
- change the keyboard shortcuts by pressing the new key combination
- choose a light or dark look or follow the system, open the window when Claude is done, and clear the history

While you press a new shortcut, the desktop's own shortcuts are off for up to 20 seconds, so that every key reaches the window; GNOME asks once whether the window may do this. A key that the desktop already uses for something else is not taken: you get a warning and first need to free it in your Hyprland settings, in Plasma's system settings or in GNOME's settings. If a shortcut does not work or is also used for something else, the response window shows it at the top, and Hyprland also shows a warning.

### Reading aloud

For a more natural voice, install Piper and run `voice-commands-setup` again, which downloads a German and an English voice. Install Piper either as the package `piper-tts` from the AUR, which is updated with your system, or with `sudo pacman -S python-pipx` and `pipx install piper-tts`, which comes straight from the Piper project but has to be updated on its own with `pipx upgrade piper-tts` (a plain `pip install` is refused on Arch). Both are the same official Piper. Code and web addresses are skipped when reading. Without Piper, the system voice from speech-dispatcher or espeak-ng is used if one is set up. The cancel shortcut also stops reading aloud.

### Background programs

If you ask for it, Claude starts programs such as a browser on an invisible display (Xvfb), looks at them with screenshots and operates them with clicks and keys. Only programs with an entry in your app launcher are allowed, but no terminals, editors, IDEs or file managers, because they can run commands. A program started with anything other than a web address, such as a file, asks first. The programs run in a sandbox that hides known places with passwords or keys and your browser profiles, so a background browser has none of your logins, and changes they make in your home folder outside `~/Voice-Commands` and the folders you shared for changing are discarded when they close. Downloads go to `~/Voice-Commands/Downloads`. They close after 15 minutes without activity, never while a command is still working, and a notification tells you when they closed; Claude can keep them open longer for a task (`voice-commands-bg keep <minutes>`). Anything unsaved in them is lost, so ask Claude to save results.

### Continue in Claude Desktop

Each response has a button that opens its session in the Claude desktop app, if you have it. This uses a link that is not officially documented for Linux, so it may stop working after an update. It is tested with the package `claude-desktop`, which repackages Anthropic's official Linux build and is in the AUR and in CachyOS's repository. Other variants may not work: changed builds such as `claude-desktop-extra` or an AppImage not added to your system may not open the link, other Claude apps do not know it, and a sandboxed app (Flatpak or Snap) may not find the session. Claude Desktop is not on Flathub. The permission checks of voice commands do not apply in the desktop app, and the session continues there separately from later voice commands.

## What Claude may do

| What | Asks you? |
|---|---|
| Read and write in its own folder `~/Voice-Commands` | no |
| Search the web and read web pages | no |
| Start and operate programs on the invisible display (editors, IDEs, file managers and terminals are refused) | no, but starting one with anything other than a web address asks |
| Read or write in folders you shared for good in the settings | no, for what you allowed |
| Reading commands such as `ls`, `cat` or `find`, within the reach you chose for each in the settings | no |
| Read or write anywhere else | yes |
| Any other command | yes |
| Places that usually hold passwords or keys, such as `~/.ssh` or `.env` | always, but a command you allowed, or any command after **Give all permissions**, can still reach them |
| Changing files that can start programs or widen Claude's rights, such as shell and desktop startup files, Git hooks, `~/.claude` and the files of Voice Commands itself | yes, even in shared folders |

The dialog shows the command or file and Claude's own description of it; what counts is the command itself. Commands that delete files or ask for administrator rights are marked. **No** is preselected and **Yes** can only be clicked after one second. Closing the dialog, not answering within 2 minutes, or any error counts as no; if the dialog of Voice Commands cannot be shown, a zenity dialog asks instead. After a no, Claude does not look for another way, but tells you what it could not do.

More rules:

- **New files** go into subfolders of `~/Voice-Commands` by topic, such as `Recipes`; a new file directly in `~/Voice-Commands` is refused, so Claude picks a fitting folder or makes one. It does not move existing files.
- **`.git` folders** ask before any change, even in `~/Voice-Commands`, because Git runs programs named in `.git/config`, even for `git status`.
- **Commands without asking** apply only to plain calls without chaining, redirection or embedded commands. Beside each file command you choose how far it reaches: the working folder only, plus shared folders, plus your personal folders (Documents, Downloads, Pictures …), your home folder without hidden folders, plus system files (`/etc`, `/usr` …), everywhere, or plus folders you choose. The last three ask for a confirmation first. System information such as `date` or `uptime` has no reach. Each command can be switched off.
- **Own commands** you add in the settings run without a dialog whenever a call starts with their words, after a warning and confirmation. Known reading programs, such as `rg`, `fd`, `diff` or `sha256sum`, get a reach to choose like the built-in ones, and their options that could run or write something still ask; all other own commands reach any place named to them. Programs that run any command given to them (sudo, shells, interpreters such as python, `env` …) cannot be added, and known risks, such as deleting files or showing access data, are named when you add one.
- **Shared folders:** `/` cannot be shared. Sharing your home folder, a system folder or a hidden folder in home such as `~/.config`, or allowing changes, asks for a confirmation with a warning.
- **The list of permissions:** with every command, Claude gets a current list of what runs without a dialog, made from your settings. It grants nothing; every step is still checked on its own.
- Claude Code's automatic memory is off for voice commands, so nothing a command hears is kept beyond its conversation.

## Risks

**Installing gives this project a lot of trust:**

- This package is not part of Arch Linux and nobody else has checked it. Read its files before you install it.
- Software you install gets full control of your computer while it installs.
- The speech recognition files and voices, about 600 MB from Hugging Face, are not signed. Voice Commands loads each one from a fixed version and checks it against a SHA-256 checksum written in `voice-commands-setup`, so a changed file is rejected. This protects against changes on the way and later changes on Hugging Face, but not against a file that was already bad when its checksum was taken.

**Claude acts on what you say:**

- Speech can be misheard. A spoken command starts by itself 5 seconds after it is recognized unless you cancel it. You can change this time or turn it off in the settings; when it is off, a misheard command starts at once.
- A continued conversation can mislead Claude, for example when it keeps following a wish from an earlier command. Turn continuing off or shorten its time in the settings if this happens.
- If you say yes to a command, it can do anything you can do, including deleting files and using your logged-in accounts. Read each dialog before you answer.
- The dialog also offers **Give all permissions for this request**. Claude then reads, writes and runs commands without asking until that request ends, which can be more access than it needs. A warning asks you to confirm this a second time. Only reading or changing known places that usually hold passwords or keys directly still asks; commands run without asking and can reach them too.
- **Shared folders** and **commands without asking** save you dialogs but widen what Claude can do unasked. Places with passwords or keys are recognized only by known names, such as `~/.ssh`, `.env` or files with "password" in their name. Access data elsewhere, for example in a program's settings or a note of your own, is read without a dialog wherever Claude may read freely. Commands you add yourself in the settings are at your own risk.
- Claude searches the web and reads web pages without asking. Claude Code itself asks for both by default; Voice Commands allows them so that spoken commands are not interrupted. Websites, documents and programs could contain text designed to trick Claude into doing something you did not ask for. One way such text could misuse this: it gets Claude to put the content of a file it may read, for example from `~/Voice-Commands` or a shared folder, into a web address, which sends it to that website without a dialog.
- **Background programs** are started and operated without a dialog, and Claude can use a running program as freely as you could, for example to open local files through a browser's address bar and look at them in a screenshot. They therefore run in a sandbox (bubblewrap): known places with passwords or keys, including the profiles of common browsers, are empty for them, and other processes and their environment are hidden. A background browser starts with an empty profile, without your logins, and its data is gone when it closes. The programs can change only `~/Voice-Commands` and folders you shared for reading and changing for good (downloads go to `~/Voice-Commands/Downloads`; a shared home folder itself and hidden folders such as `~/.config` are left out, and `.git` folders in shared folders stay read only); whatever they write elsewhere in your home folder, for example through a save dialog, goes to a layer in memory and is gone when they close, so they cannot leave startup files or settings behind. They can still read your other files, and access data outside the known places is not hidden. Outside your home folder, they can write where you can, such as `/tmp`. The session's D-Bus, the sockets of Hyprland and Wayland, the SSH agent and your own X display are out of their reach, so they cannot start commands outside the sandbox that way; in a classic X11 session whose login file lies in `/tmp`, your display may still be reachable.
- Programs with a built-in script or macro function, such as LibreOffice, GIMP, Blender, Inkscape or Krita, are not refused like editors. Claude could type a script into them that then runs inside the sandbox, with the same limits as the program itself: it can read your files, except the hidden places, and keep changes only in `~/Voice-Commands` and the folders you shared for changing.
- The permission check is part of Voice Commands, not a sealed sandbox. Claude runs as your user, and a mistake in the check could allow more than intended.
- Deleting a response in the response window also deletes its conversation from Claude Code's storage, after a few seconds in which you can undo it. For a continued conversation you can delete all of it or only remove the response from the overview, in which case Claude Code keeps it until the time set under Keep conversations. Clear history deletes all responses and all conversations of voice commands; files Claude saved in `~/Voice-Commands` are kept.
- Background programs close after 15 minutes without activity, and anything unsaved in them is lost.

**Some of your data leaves your computer:** see [Your data](#your-data).

**It has had limited testing:** I use it every day only on CachyOS with Hyprland's Lua settings. Installing and the main functions are also tested on fresh Arch Linux installations with Hyprland, KDE Plasma and GNOME (see [Supported desktops](#supported-desktops)). Other Arch-based systems and desktops may work, but have not been tried.

## Your data

- **Stays on your computer:** your voice, the speech recognition and reading aloud.
- **Goes to Anthropic:** the recognized text of your commands, everything Claude reads, including files you allow, web pages and the screenshots of background programs, and Claude's responses. Using it counts towards your Claude plan's limits.
- **Goes to others:** websites Claude opens in a background browser are loaded from your computer, as when you browse.
- **Kept on your computer:** the last 50 responses and the last 1000 lines of the log in `~/Voice-Commands`. Screenshots of background programs are kept only in memory (`$XDG_RUNTIME_DIR`) and deleted when the programs close, or at the latest at shutdown or logout.
- **Claude Code's conversation files:** Claude Code saves each conversation, including everything Claude read and the screenshots it looked at, in `~/.claude/projects`. Voice Commands deletes its own conversations there after 1, 7 or 30 days, as set in the settings, 7 by default. Other Claude Code sessions are not touched.
- Files Claude saves for you in `~/Voice-Commands` belong to you and are never deleted automatically.

## Your responsibilities

- **Anthropic's terms apply to your use.** Read the [Consumer Terms](https://www.anthropic.com/legal/consumer-terms), which restrict automated access, and the [Claude Code legal page](https://code.claude.com/docs/en/legal-and-compliance). Voice Commands runs one task for each command you give, but it is your responsibility to decide whether your use is allowed. If you are unsure, ask Anthropic or use an API key.
- **Use your own account.** Do not share your Claude login with anyone else. Everyone who uses Voice Commands needs their own account.
- **Respect other people's privacy.** Other voices near your microphone, and other people's data in programs Claude uses, can end up in text or screenshots sent to Anthropic. Do not use it with data you are not allowed to share.
- **Follow the rules of the programs and websites you automate.** Some do not allow automated use.

## If something does not work

- **The shortcuts do nothing:** Check whether the response window shows a warning at the top. Otherwise, run `voice-commands-setup` again in a terminal of your desktop session; it lists anything still missing.
- **"Nothing recognized":** Check the microphone and speak a little longer. In the settings, set the language you speak instead of detecting it.
- **Claude reports an error:** Details are in `~/Voice-Commands/log.txt`. Check that Claude Code is signed in by starting `claude` once in a terminal.
- **No notifications:** Check that your desktop's do not disturb mode is off.
- **No voice for reading aloud:** Install `piper-tts` from the AUR or with `pipx install piper-tts`, then run `voice-commands-setup` again.
- **Background programs do not start:** They need bubblewrap and the kernel module `overlay`. Run `voice-commands-setup`, which names what is missing. If `sudo modprobe overlay` says the module is not found, the kernel was updated since the last start: restart the computer.
- **Continue in Claude Desktop does nothing:** See which variants of the desktop app work under [Using it](#using-it).

## Known limitations

- No update notifications: check this repository for new versions yourself.
- No status bar on GNOME and X11, only notifications.
- Hyprland's classic `hyprland.conf` is not supported.
- Continuing in Claude Desktop uses a link Anthropic does not document for Linux.
- Waterfox shows no web pages on the invisible display (tested with Waterfox 6.7.7), so use Firefox or another browser for background programs.
- A background browser has none of your logins and forgets cookies and history when it closes, so tasks that need your accounts on websites do not work in the background.

## Update

In your copy of the repository:

```bash
sudo pacman -Syu
git pull
packaging/build-package.sh
cd aur && makepkg -si
voice-commands-setup
```

You get no update notifications this way. Changed keyboard shortcuts on Hyprland take effect after `hyprctl reload`.

## Uninstall

```bash
sudo pacman -Rns voice-commands
```

Then remove these by hand:

- on Hyprland, the Voice Commands lines in `~/.config/hypr/hyprland.lua`, and the file `~/.config/hypr/config/voice-commands.lua` if it exists
- on KDE Plasma, the files `~/.local/share/applications/local.voicecommands.*.desktop`; Plasma then drops their shortcuts
- on GNOME, the shortcuts "Voice Commands: ..." in the settings under Keyboard, View and Customize Shortcuts, Custom Shortcuts
- on other desktops, the keyboard shortcuts you added
- the link `~/.claude/skills/voice-commands`
- the speech recognition files, voices and the last 50 responses in `~/.local/share/voice-commands`
- the settings in `~/.config/voice-commands`
- the log and any files Claude saved in `~/Voice-Commands`
- Claude Code's saved conversations of voice commands, in the folder for `~/Voice-Commands` under `~/.claude/projects` (named like `-home-<you>-Voice-Commands`); they are otherwise deleted only after the days set under Keep conversations
- `/etc/modules-load.d/voice-commands.conf`, if you created it to run Voice Commands from the source folder (`sudo rm /etc/modules-load.d/voice-commands.conf`); the package's own file is removed with the package

## How it works in detail

**Programs:** Voice Commands is a set of small programs in `/usr/bin`:

| Program | Does |
|---|---|
| `voice-commands` | records, recognizes speech, waits the time to cancel, runs Claude Code and stores the response |
| `voice-commands-permission` | the permission check: Claude Code asks it before every step |
| `voice-commands-ask` | the yes or no dialog |
| `voice-commands-commands` | the lists of commands that run without asking, and the list of permissions given to Claude |
| `voice-commands-bg` | the invisible display for background programs and their protected area |
| `voice-commands-window` | the response window with the settings and the help |
| `voice-commands-input` | the window to type a command |
| `voice-commands-overlay` | the status bar |
| `voice-commands-speak` | reading aloud with Piper or the system voice |
| `voice-commands-markdown` | turns Markdown into text for the window, notifications and reading aloud |
| `voice-commands-shortcuts` | writes and checks the keyboard shortcuts on Hyprland, KDE Plasma and GNOME |
| `voice-commands-theme` | the shared look of the windows |
| `voice-commands-setup` | the setup for your user |

**One command, step by step:**

1. `voice-commands toggle` records with PipeWire (`pw-record`, 16 kHz mono) into `$XDG_RUNTIME_DIR/voice-commands`, which lives in memory, for at most 5 minutes.
2. The second press ends the recording. whisper.cpp (`whisper-cli` with the model `ggml-small.bin`) turns it into text; voice detection (Silero) first cuts out pauses, in which whisper could otherwise invent text. The recording is deleted, filler words are removed, and empty results or labels such as `[Music]` count as nothing recognized.
3. During the time to cancel, the cancel shortcut stops the command and the send shortcut starts it at once.
4. Commands run one after another: each waits for a lock until the one before it has finished.
5. `voice-commands` starts `claude -p` in `~/Voice-Commands` with:
   - `--permission-mode dontAsk`, so that Claude Code itself never shows a question, and a hook (`PreToolUse`) that runs `voice-commands-permission` before every step; it allows, refuses or shows the yes or no dialog, and a failed or timed out check refuses the step
   - a second hook (`PostToolUse`) that notes each file Claude writes, for the list of files below the response; new files in `~/Voice-Commands` are found as well
   - instructions added to Claude's own (`--append-system-prompt`): how to handle misheard text, where to save files, how to use background programs, and the current list of permissions
   - `-c` to continue the last conversation, if the last command ended less than the set time ago or you asked to continue
   - `--model`, if you chose a model in the response window
   - automatic memory turned off
6. The response is stored with your command, the time, the conversation's ID and the list of files. A notification shows its beginning, and if set, it is read aloud and the window opens.

**Background programs** run on the X display `:77` (Xvfb, 1920×1080), which no screen shows. `voice-commands-bg` starts them in bubblewrap, takes screenshots with ImageMagick, clicks and types with xdotool, and only keeps the last 20 screenshots. Inside bubblewrap, the home folder is an overlay in memory; `~/Voice-Commands` and folders shared for changing are mounted for real, the places with secrets are replaced by empty ones, other processes are hidden, and the runtime folder and the user's own displays are left out. A watcher closes everything after 15 minutes without activity.

**Your files:**

| Where | What |
|---|---|
| `~/Voice-Commands` | Claude's working folder: your files from Claude, `log.txt` (the last 1000 lines) |
| `~/.config/voice-commands` | `settings.json` (settings and shortcuts), `model` (the chosen model), `shortcuts.lua` (Hyprland) |
| `~/.local/share/voice-commands` | speech recognition files, voices, `antworten.jsonl` (the last 50 responses) |
| `$XDG_RUNTIME_DIR/voice-commands` and `.../voice-commands-bg` | recording, queue, status, screenshots; in memory, gone at logout |
| `~/.claude/projects/-home-<you>-Voice-Commands` | Claude Code's conversations of voice commands, deleted after the days set |
| `~/.claude/skills/voice-commands` | instructions for Claude Code on updating Voice Commands |

**Commands for scripts and other desktops:** `voice-commands toggle`, `cancel`, `send`, `typed <text>` (runs a typed command), `voice-commands-window`, `voice-commands-input`, and `voice-commands-bg start|windows|shot|click|focus|type|key|keep|stop`.

**Environment variables:** `VOICE_COMMANDS_MODEL` chooses the model (such as `sonnet`), `VOICE_COMMANDS_LANG` the language of the interface (such as `de` or `en`), and `VOICE_COMMANDS_BG_IDLE_SECONDS` the time until background programs close (900 by default).

## Development

To try changes without installing, run `bin/voice-commands-setup` from your copy of the source. Voice Commands then runs from there, and changes take effect right away. `/usr/bin/voice-commands-setup` switches back to the installed package.

`tests/permission-hook.sh` tests the permission check and the protected area of background programs with over 160 cases in a temporary home folder, without touching yours and without opening a window (`-v` lists every case). Run it after every change to `voice-commands-permission`, `voice-commands-commands` or `voice-commands-bg`. The cases for the protected area need the kernel module `overlay` and are skipped otherwise.

For a new version, raise `pkgver` or `pkgrel` in `packaging/PKGBUILD`. `packaging/build-package.sh` builds the package folder `aur/`, from which `makepkg` builds the package. Notable changes are listed in [CHANGELOG.md](CHANGELOG.md).

Not stored in this repository: speech recognition files and voices (downloaded by `voice-commands-setup`) and the response history and log in `~/Voice-Commands`.

## License

Voice Commands is released under the [MIT License](LICENSE).

The license covers only the files in this repository. `voice-commands-setup` downloads further files from Hugging Face, which have their own licenses:

| File | Source | License |
|---|---|---|
| Speech recognition (`ggml-small.bin`) | [ggerganov/whisper.cpp](https://huggingface.co/ggerganov/whisper.cpp) | MIT |
| Voice detection (`ggml-silero-v5.1.2.bin`) | [ggml-org/whisper-vad](https://huggingface.co/ggml-org/whisper-vad) | MIT |
| German voice (Piper, thorsten medium) | [rhasspy/piper-voices](https://huggingface.co/rhasspy/piper-voices/tree/main/de/de_DE/thorsten/medium) | dataset CC0; the model was fine-tuned from the lessac voice, whose dataset allows research use only |
| English voice (Piper, ljspeech medium) | [rhasspy/piper-voices](https://huggingface.co/rhasspy/piper-voices/tree/main/en/en_US/ljspeech/medium) | dataset in the public domain |

Check these licenses yourself before using the voices for anything other than personal use. Programs such as Claude Code, whisper.cpp and Piper are not included and keep their own licenses.
