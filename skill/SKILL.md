---
name: voice-commands
description: Update or change Voice Commands (spoken commands for Claude Code), or publish a new version. Use when the user wants to update, sync or change the voice control, in any language.
---

# Voice Commands

Always talk to the user in their language.

Voice Commands is unofficial and not affiliated with Anthropic. Never put Claude, Claude Code or Anthropic into the project's name, package name, logo or anything that suggests a connection; plain statements of what it works with are fine. Keep the responsibilities in the README up to date, and do not add loops or unattended repeated runs without discussing Anthropic's terms on automated access with the user.

Voice Commands is installed as the pacman package `voice-commands`, usually from its own pacman repository `[voice-commands]` in `/etc/pacman.conf` (a release of the GitHub repository `https://github.com/deehax999-source/voice-commands`, packages not signed), or built from that repository. It is not in the AUR.

## Update

If `/etc/pacman.conf` has the section `[voice-commands]`, give the user this command, because it asks for a password:

```bash
sudo pacman -Syu
```

Otherwise, in the user's copy of the repository, run `git pull` and `packaging/build-package.sh`, then give the user this command:

```bash
cd aur && makepkg -si
```

Then run `voice-commands-setup` if the setup changed, and `hyprctl reload` on Hyprland if the keyboard shortcuts changed.

## Change something

Work in the user's own copy of the source if they have one, otherwise clone it from `https://github.com/deehax999-source/voice-commands.git`. Never change files under `/usr`. In the source, the files are in `bin/`, `hypr/`, `desktop/` and `packaging/`; `packaging/build-package.sh` copies them into one flat folder `aur/`.

The repository is public: never add personal data or credentials, and check for them before every commit.

New required packages go in `depends` in the `PKGBUILD`. Keep the tool working on any Arch-based system: do not assume CachyOS, Hyprland or Wayland, and let optional parts fail gracefully.

After changing `voice-commands-permission`, `voice-commands-commands` or `voice-commands-bg`, run `tests/permission-hook.sh` and add a case for each new rule. Never loosen the permission check or the protected area of background programs (bubblewrap) without the user's explicit agreement, and explain what it opens.

Keep the help in `help/de.md` and `help/en.md` up to date when something changes that users see.

Setup and update messages are in plain English that anyone can understand. Notifications, the status bar and the response window follow the system language, so add new text in both German and English.

## Publish

Only the maintainer can publish. Other users can share their changes as a pull request or an issue on GitHub. For the maintainer, only when they explicitly ask:

1. Raise `pkgver` or `pkgrel` in `packaging/PKGBUILD` and add an entry to `CHANGELOG.md`.
2. Run `packaging/build-package.sh` and test the package.
3. Commit and push to the GitHub repository.
4. Run `packaging/publish-repo.sh`, which uploads the package and a new database to the release `repo`, so that computers with the repository get the update with `sudo pacman -Syu`.
