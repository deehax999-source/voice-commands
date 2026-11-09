# Voice Commands help

With Voice Commands, you speak an instruction and Claude Code carries it out on your computer. Voice Commands is an unofficial project and is not part of Anthropic.

## Keyboard shortcuts

- **{toggle}**: Start recording. Press it again to finish recording and send the command.
- **{cancel}**: Cancel. Stops a recording, a command that is starting or running, and reading aloud.
- **{window}**: Open this response window. It is also in your app launcher as **Voice Commands**.
- **{send}**: Send the recognized command right away, without waiting for the time to cancel. During a recording it also ends the recording.
- **{type}**: Open a text field to type a command, for example when you cannot speak or no microphone is connected. Enter sends, Shift+Enter starts a new line, Esc closes. A typed command starts without the time to cancel and otherwise runs like a spoken one.

Change the shortcuts in **Settings → Keyboard shortcuts**.

## How a voice command works

1. **Recording:** Press {toggle} and speak. A status bar at the top of the screen shows the recording time. Recording stops by itself after 5 minutes.
2. **Recognition:** Press {toggle} again. Your speech is turned into text on your computer. Filler words such as "um" are removed.
3. **Time to cancel:** A notification shows what was understood. You now have a few seconds to cancel with {cancel} if something was misheard. {send} starts it right away. Set this time in the settings, where it can also be turned off.
4. **Working:** Claude works. The status bar shows for how long. Further commands wait and run afterwards.
5. **Response:** A notification shows the beginning of the response. **Open response** brings you here. If you like, the response is also read aloud.

**Tip:** Speak freely. If you correct yourself ("no, I mean ..."), the last version counts. If a command is unclear or would have effects that cannot be undone, Claude asks in its response instead of carrying it out.

## Continuing and follow-up questions

If you give another command within 5 minutes of the last one, Claude continues the same conversation and knows the context. After that, a new conversation starts. Set the time under **Settings → Continue the conversation automatically**: off, 5, 15 or 30 minutes. A long conversation can also mislead Claude, for example when it keeps following earlier requests for files. Phrases such as "continue" or "where we left off" make Claude continue the last conversation later as well.

## What Claude may do

Claude has its own folder, `~/Voice-Commands`, where it may read and write without asking. For everything else, a yes or no window appears:

- **Reading files** outside that folder, including searching folders.
- **Creating or changing files** outside that folder.
- **Running commands.** You see the command and Claude's own description of it. What counts is the command. Commands that delete files or ask for administrator rights are marked.
- **Other tools**, such as connected services.

In the yes or no window, **No** is preselected, and **Yes** can only be clicked after one second, so that no accidental click allows anything. If you do not answer within 2 minutes, the answer is **no**; a bar shows the time left. After a no, Claude does not look for another way, but tells you what it could not do.

**All permissions for this request:** With this button, Claude does not ask again until the current command ends. A second warning comes first. Only when Claude wants to read or change known places that often hold passwords or keys directly does it still ask. Commands then run without asking and can reach these places too. Voice Commands recognizes them only by fixed names and can miss others. Use this only if you know exactly what the command will do.

**Commands without asking:** The settings list, under "Commands without asking", commands that run without a yes or no dialog: system information such as `date` or `uptime`, and reading file commands such as `ls`, `cat` or `find`. Choose beside each file command how far it reaches without a dialog: working folder only, plus shared folders, plus your personal folders (Documents, Downloads, Pictures …), your home folder without hidden folders, plus system files (/etc, /usr …), everywhere, or plus own folders set with the folder button beside it. The working folder is always included; elsewhere Claude asks. You can switch each off and on again later. Under "Own commands" you add more at your own risk; everything that starts with these words then runs without a dialog. Known reading programs such as `rg`, `fd`, `diff`, `sort` or `sha256sum` get a drop-down for their reach as well, at first only the working folder; options with which they could run or write something always ask. All other own commands may read any place Claude names to them. Read the note "Own commands at your own risk" first. With every command, Claude gets a current list of what runs without a dialog right now and prefers those ways. The list grants nothing; every call is still decided on its own. For known risks, such as programs that delete files, run commands from project files or show access data, the confirmation names the risk. Programs such as `printenv`, `ps`, `journalctl`, `gpg` or `gh` show access data without naming a place; the protection for places with passwords or keys does not apply to them. sudo, shells and programs such as python or env cannot be allowed. Built-in commands such as `wc` cannot be added again as own commands; choose their reach in the drop-down beside them. All of this only applies to plain calls without chaining, redirection or embedded commands, and known places with passwords or keys always ask. Voice Commands recognizes these only by fixed names, such as `~/.ssh`, `.env` or files with "password" in their name. It does not recognize access data elsewhere, for example in settings files of programs, in `/etc` or in a note of your own. The further a command reaches, the more likely Claude can read such files without a dialog, so choosing "Home without hidden folders", "+ system files" or "Everywhere" shows a warning first.

**Shared folders:** In the settings (gear button), under "Shared folders", you can share folders for good, as in the desktop app. Claude may read there without asking, and if you choose "Read and change", also create and change files. Commands still ask, and so do known places with passwords or keys and files that can start programs, such as settings in `~/.config/hypr` or Git hooks. Voice Commands recognizes passwords and keys only by known names such as `~/.ssh` or `.env`; Claude reads other access data in shared folders without a dialog, for example in a note of your own. What Claude reads is sent to Anthropic, so share only the folders Claude really needs, not your whole home folder. Tips are in the settings under "What to watch out for". A warning comes first before you choose "Read and change" or share your home folder, a system folder or a settings folder such as `~/.config`.

Claude may search the web and read websites without asking.

## Programs in the background

Claude can operate programs on an invisible display without using your screen. For this, it takes screenshots of that invisible display. These programs close after 15 minutes without activity, and unsaved content is lost. So tell Claude to save results.

Starting and operating them does not ask. If Claude starts a program with anything other than a web address, such as a file, you are asked first. Editors, IDEs, file managers and terminals cannot be started at all, because they can run commands. A running program can be operated freely, as you could, for example to open files through a browser's address bar and look at them in the screenshot. That is why background programs run in a protected area (bubblewrap): known places with passwords or keys such as `~/.ssh` and the profiles of your browsers are empty for them, and other programs and their environment are out of sight. A background browser therefore starts with an empty profile, without your logins. They can change only your working folder `~/Voice-Commands` and folders you shared for reading and changing; downloads go to `~/Voice-Commands/Downloads`. A shared home folder itself and hidden folders such as `~/.config` are left out, and `.git` folders stay read only. Whatever they write elsewhere in your home folder, for example through a save dialog, is gone when they close. Your other files they can read as you can. Programs with their own script or macro function, such as LibreOffice, GIMP or Blender, are allowed; a script in them runs with the same limits as the program. For this, the package loads the kernel module `overlay` when the computer starts.

## The response window

- It shows the last 50 responses, newest first, with the time and your command. Long responses show only their first three lines; **Show the whole response** unfolds them and **Show less** folds them again. All are folded again when the window opens. Copy and read aloud always take the whole response.
- **Files below a response:** files Claude created or changed for this command. A click opens one with its usual program, a right-click shows it in its folder. Programs and scripts are not opened directly, for safety, only shown in their folder. Greyed out means the file is gone.
- **Folder button at the top:** opens the working folder `~/Voice-Commands`, where Claude saves its files. Claude sorts new files there into subfolders by topic, such as `Recipes`, using a fitting existing folder or making a new one. It does not move existing files. If you name a folder or file name, Claude uses it.
- **Speaker button:** reads the whole response aloud. Press it again to stop.
- **Question mark button at the top (F1):** opens this help. Its speaker button at the top left reads it aloud; press it again or close the help to stop.
- **Copy:** copies the response with its Markdown marks, so that its structure is kept when you paste it. You can also select text.
- **Continue in Claude Desktop:** opens the conversation in the Claude desktop app, if you have it. The yes or no questions of Voice Commands do not apply there. On Linux, this link is not official and may stop working after an update. It is tested with the package `claude-desktop` from the AUR or CachyOS's repository. It may not work with other variants, such as Flatpak, Snap or an AppImage.
- **Trash button:** deletes the response and its conversation from Claude Code's storage. For a few seconds, **Undo** takes it back. If the response belongs to a continued conversation, a question lists all responses of that conversation. Claude Code stores a conversation only as a whole, so **Delete the whole conversation** deletes all of them. **Only remove from the overview** removes just this one response from the window; Claude Code's record then keeps it until the time under **Keep conversations** runs out.
- **Model:** At the top left, choose the Claude model for voice commands. Regular Claude Code sessions stay unchanged.
- A bar at the top warns if a keyboard shortcut does not work or is used twice.

## Settings

The gear at the top right opens the settings. Changes only take effect when you apply them in the bar at the bottom; "Discard" keeps everything as it was. If you close the settings with changes left, Voice Commands asks.

- **Color scheme:** light, dark or following the system. Also applies to the yes or no windows and the status bar.
- **Read responses aloud:** reads new responses aloud automatically, either only the first paragraph or everything, slow, normal or fast. Code and web addresses are skipped. With Piper, the voice sounds more natural. Without Piper, a system voice is used if one is set up.
- **Spoken language:** helps speech recognition. "Detect automatically" is useful if you switch between languages.
- **Time before starting:** 3, 5 or 10 seconds to cancel, or off. When it is off, a command starts as soon as it is recognized and can only be stopped with {cancel} while it runs.
- **Keyboard shortcuts:** With **Change**, simply press the new combination. Meanwhile, the desktop's shortcuts are off for 20 seconds at most, so that every key arrives. Escape cancels. A key that is already used for something else is not taken. Free it first: on Hyprland in your Hyprland settings, on KDE Plasma in the system settings under Keyboard → Shortcuts, on GNOME in the settings under Keyboard → View and Customize Shortcuts. GNOME asks the first time whether the window may turn its shortcuts off for a moment. This works on Hyprland, KDE Plasma and GNOME; on other desktops, set the shortcuts in your keyboard settings.
- **Keep conversations:** how long conversations, with everything Claude read, are kept.
- **Look for updates:** At most once a day, a voice command asks GitHub for the newest version. If there is a new one, a notification names it once, and the response window shows it at the top. **Update** opens a terminal that gets the new version, shows what changed and installs it. There it asks for your password and whether to go on.
- **Open when Claude is done:** shows every response in this window right away.
- **Clear history:** deletes all saved responses and all conversations of voice commands in Claude Code's storage. No conversation can be continued afterwards. Files Claude saved in `~/Voice-Commands` are kept.

## Your data

- **Stays on your computer:** your voice, speech recognition and reading aloud.
- **Goes to Anthropic:** the recognized text, everything Claude is allowed to read, and the screenshots of background programs. Voice commands count towards your Claude plan's limits.
- **Goes to GitHub:** at most once a day the question for the newest version, so GitHub sees your IP address. Turn it off under **Settings → Privacy**.
- **Kept:** the last 50 responses and the last 1000 lines of the log in `~/Voice-Commands`. Screenshots are only kept in memory. They are deleted when the background programs close, or at the latest when you shut down or log out.
- **Claude Code's conversation files:** Claude Code saves each conversation in `~/.claude/projects`, with everything Claude read, including the screenshots it looked at. Voice Commands deletes its own conversations after the time you choose in **Settings → Privacy**: 1, 7 or 30 days, 7 by default. After that, they can no longer be continued or opened in Claude Desktop. Your other Claude Code sessions stay unchanged.
- Whatever Claude saves for you in `~/Voice-Commands` belongs to you and is never deleted automatically.

Other voices near your microphone and other people's data in programs can also reach Anthropic. Do not use Voice Commands with data you are not allowed to share.

## If something does not work

- **The shortcuts do nothing:** Check whether a warning bar is shown at the top of this window. Otherwise, run `voice-commands-setup` in a terminal.
- **"Nothing recognized":** Check the microphone and speak a little longer. Under **Spoken language**, you can set the language.
- **Claude reports an error:** Details are in `~/Voice-Commands/log.txt`. Check that Claude Code is signed in by starting `claude` once in a terminal.
- **Background programs do not start:** They need bubblewrap and the kernel module `overlay`. Run `voice-commands-setup`, which names what is missing. If `sudo modprobe overlay` fails with `FATAL: Module overlay not found`, the kernel was updated since the last start and the old one's modules were deleted: restart the computer. This often happens right after the installation, when it brought a new kernel too.
- **No voice for reading aloud:** Install `piper-tts` from the AUR or with `pipx install piper-tts` (first `sudo pacman -S python-pipx`), then run `voice-commands-setup`. Update the pipx version yourself with `pipx upgrade piper-tts`.
- **Hyprland shows a warning about Voice Commands:** Run `voice-commands-setup`. If this window still shows a warning afterwards, change that shortcut.

## Uninstalling

Remove the package with `sudo pacman -Rns voice-commands`. What else to delete afterwards is in the README at `/usr/share/doc/voice-commands/README.md`.
