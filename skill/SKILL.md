---
name: voice-commands
description: Update or change Voice Commands (spoken commands for Claude Code), or publish a new version. Use when the user wants to update, sync or change the voice control, in any language.
---

# Voice Commands

Always talk to the user in their language.

Voice Commands is unofficial and not affiliated with Anthropic. Never put Claude, Claude Code or Anthropic into the project's name, package name, logo or anything that suggests a connection; plain statements of what it works with are fine. Keep the responsibilities in the README up to date, and do not add loops or unattended repeated runs without discussing Anthropic's terms on automated access with the user.

Voice Commands is built from its GitHub repository `https://github.com/deehax999-source/voice-commands` and installed as the pacman package `voice-commands`. It is not in the AUR or any pacman repository; at most once a day, a voice command checks GitHub for a new version and notifies the user (setting `update_check`).

## Update

The simplest way is `voice-commands update` in a terminal (the button Update in the update notification or the response window opens one): it gets the newest version from GitHub into a temporary folder, builds and installs it with `makepkg -si`, which asks for the password, and runs the setup. Give the user this command rather than running it, because it asks for a password. To update from the user's own copy instead: in the user's copy of the repository, run `git pull` and `packaging/build-package.sh`. Then give the user this command, because it asks for a password:

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
3. Commit and push to the GitHub repository. The update check of installed copies reads `pkgver` and `pkgrel` from `packaging/PKGBUILD` on `main`, so raise them only in the commit that publishes.
