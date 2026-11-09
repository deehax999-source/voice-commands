#!/usr/bin/env bash
# Tests for bin/voice-commands-permission, the hook that decides each tool use.
#
#     tests/permission-hook.sh          runs all cases and prints only failures and a summary
#     tests/permission-hook.sh -v       prints every case
#
# Each case runs the hook with an empty temporary home, config and runtime folder, so the real home is
# never read or changed. The yes or no window is replaced by a stub (VOICE_COMMANDS_DIALOG) that
# answers from a list and records every question it was asked. Needs bash, jq, python3 and coreutils.
set -u

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO/bin/voice-commands-permission"
VERBOSE=0
[ "${1:-}" = -v ] && VERBOSE=1

T="$(mktemp -d)"
trap 'rm -rf -- "$T"' EXIT
H="$T/home"
W="$H/Voice-Commands"
RUN="$T/run"
CONFIG="$H/.config/voice-commands"
mkdir -p "$W/Rezepte" "$W/repo/.git/hooks" "$H/.ssh" "$H/Documents" "$H/Shared" "$H/ReadOnly" \
    "$H/.config/hypr" "$CONFIG" "$RUN/voice-commands-bg/shots" "$H/proj/.git" "$H/.local/share/voice-commands"
chmod 700 "$RUN"
: >"$W/Rezepte/Kuchen.md"
: >"$W/old.txt"
: >"$H/.local/share/voice-commands/antworten.jsonl"
: >"$H/.ssh/id_ed25519"
: >"$H/Documents/letter.txt"
: >"$H/Documents/.env"
: >"$RUN/voice-commands-bg/shots/1.png"
ln -s "$H/.ssh" "$W/keys"
ln -s "$H/Documents" "$W/docs"
ln -s "$H/.bashrc" "$W/Rezepte/rc"

# The stub window: one answer per call from $T/answers (yes, no, extra or fail; no when the list is
# empty), and one line per call in $T/calls with all its arguments
cat >"$T/dialog" <<'EOF'
#!/usr/bin/env bash
dir="$(dirname -- "$0")"
line="" extra=""
for a in "$@"; do
    case "$a" in --extra-button=*) extra="${a#--extra-button=}" ;; esac
    line="$line${a//$'\n'/ } | "
done
printf '%s\n' "$line" >>"$dir/calls"
answer="$(head -n 1 "$dir/answers" 2>/dev/null)"
sed -i 1d "$dir/answers" 2>/dev/null
case "$answer" in
    yes) exit 0 ;;
    extra) printf '%s\n' "$extra"; exit 1 ;;
    fail) exit 5 ;;
    *) exit 1 ;;
esac
EOF
chmod +x "$T/dialog"

PASS=0
FAIL=0
TASK=""
LANGUAGE=C
DECISION="" REASON=""

settings() { printf '%s' "$1" >"$CONFIG/settings.json"; }
no_settings() { rm -f -- "$CONFIG/settings.json"; }
grants() { printf '%s' "$RUN/voice-commands/grants/$1"; }

# Runs the hook with this JSON on stdin and these answers for the stub window
run() {
    local json="$1"; shift
    printf '%s\n' "$@" >"$T/answers"
    : >"$T/calls"
    local out
    out="$(printf '%s' "$json" | env -i PATH="$PATH" HOME="$H" XDG_CONFIG_HOME="$H/.config" \
        XDG_RUNTIME_DIR="$RUN" LANG="$LANGUAGE" VOICE_COMMANDS_DIALOG="$T/dialog" \
        ${TASK:+VOICE_COMMANDS_TASK="$TASK"} timeout 20 "$HOOK" 2>"$T/stderr")"
    DECISION="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // "none"' 2>/dev/null)"
    REASON="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null)"
    [ -n "$DECISION" ] || DECISION="invalid output: $out"
}

calls() { wc -l <"$T/calls"; }

# expect NAME DECISION DIALOGS [TEXT]: the last run gave this decision after this many questions, and
# TEXT (if given) appeared in a question
expect() {
    local name="$1" decision="$2" dialogs="$3" text="${4:-}" problem=""
    [ "$DECISION" = "$decision" ] || problem="decision $DECISION, expected $decision"
    [ "$(calls)" -eq "$dialogs" ] || problem="${problem:+$problem; }$(calls) questions, expected $dialogs"
    if [ -n "$text" ] && ! grep -qF -- "$text" "$T/calls"; then
        problem="${problem:+$problem; }no question contained: $text"
    fi
    result "$name" "$problem"
}

# result NAME PROBLEM: counts a case, which passed if PROBLEM is empty
result() {
    if [ -z "$2" ]; then
        PASS=$((PASS + 1))
        [ "$VERBOSE" = 0 ] || echo "ok    $1"
    else
        FAIL=$((FAIL + 1))
        echo "FAIL  $1: $2"
        [ ! -s "$T/stderr" ] || sed 's/^/      stderr: /' "$T/stderr"
    fi
}

tool() { jq -nc --arg t "$1" --arg cwd "${3:-$W}" --argjson i "$2" '{tool_name:$t, cwd:$cwd, tool_input:$i}'; }
read_json() { tool Read "$(jq -nc --arg p "$1" '{file_path:$p}')"; }
write_json() { tool Write "$(jq -nc --arg p "$1" '{file_path:$p, content:"x"}')"; }
edit_json() { tool Edit "$(jq -nc --arg p "$1" '{file_path:$p, old_string:"a", new_string:"b"}')"; }
bash_json() { tool Bash "$(jq -nc --arg c "$1" '{command:$c}')" "${2:-$W}"; }

SECRETS="passwords or keys"
OUTSIDE="outside your home folder"
PROTECTED="That is why Voice Commands asks anyway"
DELETES="deletes files or folders"
ADMIN="administrator rights"

no_settings

echo "== Requests that cannot be read"
run 'not json'; expect "invalid JSON is denied" deny 0
run ''; expect "empty input is denied" deny 0
run '{"tool_input":{}}'; expect "missing tool name is denied" deny 0

echo "== Reading"
run "$(read_json "$W/Rezepte/Kuchen.md")"; expect "file in the working folder" allow 0
run "$(read_json "Rezepte/Kuchen.md")"; expect "relative path from the working folder" allow 0
run "$(read_json "~/Voice-Commands/old.txt")"; expect "path with ~" allow 0
run "$(read_json "$H/Documents/letter.txt")" no; expect "file elsewhere in home asks, no is no" deny 1 "would be sent to Anthropic"
run "$(read_json "$H/Documents/letter.txt")" yes; expect "file elsewhere in home, yes is yes" allow 1
run "$(read_json "$H/Documents/letter.txt")" fail; expect "a failing window counts as no" deny 1
run "$(read_json "/etc/hostname")"; expect "outside home asks with a note" deny 1 "$OUTSIDE"
run "$(read_json "$H/.ssh/id_ed25519")"; expect "~/.ssh asks with the secrets note" deny 1 "$SECRETS"
run "$(read_json "$H/Documents/.env")"; expect ".env asks with the secrets note" deny 1 "$SECRETS"
run "$(read_json "$H/Documents/server.pem")"; expect "*.pem asks with the secrets note" deny 1 "$SECRETS"
run "$(read_json "/proc/1/environ")"; expect "/proc/*/environ asks with the secrets note" deny 1 "$SECRETS"
run "$(read_json "$H/.config/mozilla/firefox/x.default-release/logins.json")"; expect "the Firefox profile in ~/.config/mozilla is secret" deny 1 "$SECRETS"
run "$(read_json "$H/.mozilla/firefox/profiles.ini")"; expect "the old Firefox profile in ~/.mozilla is secret" deny 1 "$SECRETS"
run "$(read_json "$W/.env")"; expect "a secret file in the working folder still asks" deny 1 "$SECRETS"
run "$(read_json "$W/../.ssh/id_ed25519")"; expect "\"..\" out of the working folder" deny 1 "$SECRETS"
run "$(read_json "$W/keys/id_ed25519")"; expect "a link in the working folder to ~/.ssh" deny 1 "$SECRETS"
run "$(read_json "$W/docs/letter.txt")"; expect "a link in the working folder to ~/Documents" deny 1
run "$(read_json "$RUN/voice-commands-bg/shots/1.png")"; expect "screenshot of the background display" allow 0
run "$(read_json "$RUN/voice-commands/grants/x")"; expect "other runtime files ask" deny 1 "$OUTSIDE"

echo "== Searching"
run "$(tool Grep '{"pattern":"x"}')"; expect "Grep without a path searches the working folder" allow 0
run "$(tool Grep "$(jq -nc --arg p "$H" '{pattern:"x", path:$p}')")"; expect "Grep on home contains secrets" deny 1 "$SECRETS"
run "$(tool Grep "$(jq -nc --arg p "$H/Documents" '{pattern:"x", path:$p}')")"; expect "Grep on ~/Documents asks" deny 1 "would be sent"
run "$(tool Glob '{"pattern":"**/*.md"}')"; expect "Glob in the working folder" allow 0
run "$(tool Glob '{"pattern":"/etc/*.conf"}')"; expect "Glob with its own absolute path" deny 1 "$OUTSIDE"
run "$(tool Glob '{"pattern":"../.ssh/*"}')"; expect "Glob with \"..\" out of the working folder" deny 1 "$SECRETS"
run "$(tool Glob '{"pattern":"~/.ssh/*"}')"; expect "Glob with ~ to ~/.ssh" deny 1 "$SECRETS"

echo "== Writing"
run "$(write_json "$W/Rezepte/Brot.md")"; expect "new file in a subfolder of the working folder" allow 0
run "$(write_json "$W/Neu/Datei.md")"; expect "new file in a new subfolder" allow 0
run "$(write_json "$W/neu.txt")"; expect "new file at the top of the working folder is denied" deny 0
result "the denial explains subfolders" "$([[ "$REASON" == *subfolder* ]] || echo "reason: $REASON")"
run "$(write_json "$W/old.txt")"; expect "existing file at the top may be rewritten" allow 0
run "$(edit_json "$W/old.txt")"; expect "existing file at the top may be edited" allow 0
run "$(edit_json "$H/.local/share/voice-commands/antworten.jsonl")"; expect "the history of the response window asks" deny 1 "history of the response window"
run "$(write_json "$H/.local/share/voice-commands/antworten.jsonl")"; expect "overwriting the history asks" deny 1 "history of the response window"
run "$(write_json "$W/repo/.git/config")"; expect ".git/config in the working folder asks" deny 1 "$PROTECTED"
run "$(write_json "$W/repo/.git/hooks/pre-commit")"; expect ".git/hooks in the working folder asks" deny 1 "$PROTECTED"
run "$(write_json "$W/.env")"; expect ".env in the working folder asks" deny 1 "$SECRETS"
run "$(write_json "$W/Rezepte/rc")"; expect "a link in the working folder to ~/.bashrc" deny 1
run "$(write_json "$H/Documents/x.txt")"; expect "elsewhere in home asks" deny 1
run "$(write_json "$H/Documents/x.txt")" yes; expect "elsewhere in home, yes is yes" allow 1
run "$(write_json "/etc/x")"; expect "outside home asks with a note" deny 1 "$OUTSIDE"
run "$(write_json "$RUN/voice-commands-bg/shots/2.png")"; expect "the screenshot folder is not writable" deny 1
run "$(tool NotebookEdit "$(jq -nc --arg p "$W/Rezepte/n.ipynb" '{notebook_path:$p}')")"; expect "NotebookEdit in the working folder" allow 0

echo "== Shared folders"
settings "$(jq -nc --arg s "$H/Shared" --arg r "$H/ReadOnly" \
    '{folders:[{path:$s, write:true}, {path:$r, write:false}, {path:"/", write:true}, {path:"relative", write:true}]}')"
: >"$H/ReadOnly/a.txt"
run "$(read_json "$H/Shared/a.txt")"; expect "reading a shared folder" allow 0
run "$(read_json "$H/ReadOnly/a.txt")"; expect "reading a read-only shared folder" allow 0
run "$(write_json "$H/Shared/a.txt")"; expect "writing a shared folder" allow 0
run "$(write_json "$H/ReadOnly/b.txt")"; expect "writing a read-only shared folder asks" deny 1
run "$(read_json "$H/Shared/.env")"; expect "a secret file in a shared folder still asks" deny 1 "$SECRETS"
run "$(write_json "$H/Shared/proj/.git/config")"; expect ".git/config in a shared folder asks" deny 1 "$PROTECTED"
run "$(read_json "/etc/hostname")"; expect "\"/\" is never shared" deny 1 "$OUTSIDE"
run "$(read_json "$H/../home/Shared/a.txt")"; expect "a shared path with \"..\" is resolved" allow 0
run "$(bash_json "ls $H/Shared")"; expect "commands still ask in a shared folder" deny 1

settings "$(jq -nc --arg h "$H" --arg repo "$REPO" '{folders:[{path:$h, write:true}, {path:$repo, write:true}]}')"
run "$(write_json "$H/notes.txt")"; expect "writing a shared home" allow 0
for place in .bashrc .zshrc .profile .config/hypr/hyprland.lua .config/voice-commands/settings.json \
        .claude/settings.json .local/bin/x .local/share/applications/x.desktop .config/autostart/x.desktop \
        .config/systemd/user/x.service .config/user-dirs.dirs .gitconfig .config/fish/config.fish \
        .vimrc .config/nvim/init.lua .emacs.d/init.el .tmux.conf .config/kitty/kitty.conf \
        .config/Code/User/settings.json ".config/Code - OSS/User/settings.json" .config/mimeapps.list \
        .local/share/dbus-1/services/x.service .config/plasma-workspace/env/x.sh .config/sway/config \
        .config/quickshell/shell.qml .config/noctalia/settings.json .config/waybar/config \
        .local/share/voice-commands/voices/de.onnx; do
    run "$(write_json "$H/$place")"; expect "protected in a shared home: ~/$place" deny 1 "$PROTECTED"
done
run "$(write_json "$H/.local/share/voice-commands/antworten.jsonl")"; expect "the history in a shared home asks" deny 1 "history of the response window"
run "$(write_json "$H/.ssh/config")"; expect "~/.ssh in a shared home asks" deny 1 "$SECRETS"
run "$(write_json "$H/proj/.git/hooks/post-checkout")"; expect "Git hooks in a shared home ask" deny 1 "$PROTECTED"
run "$(write_json "$REPO/bin/voice-commands-permission")"; expect "the programs of Voice Commands ask" deny 1 "$PROTECTED"
run "$(write_json "$REPO/README.md")"; expect "the source folder asks" deny 1 "$PROTECTED"

settings '{"folders": [ broken'
run "$(read_json "$H/Shared/a.txt")"; expect "broken settings share nothing" deny 1
no_settings

echo "== Commands"
run "$(bash_json "voice-commands-bg shot")"; expect "plain call of the background tool" allow 0
run "$(bash_json "voice-commands-bg start firefox")"; expect "background tool with a program" allow 0
run "$(bash_json "voice-commands-bg shot; rm -rf ~")"; expect "chained after the background tool asks" deny 1 "$DELETES"
run "$(bash_json 'voice-commands-bg shot $(id)')"; expect "embedded command after the background tool asks" deny 1
run "$(bash_json "voice-commands-bg shot"$'\n'"id")"; expect "a second line after the background tool asks" deny 1
run "$(bash_json "voice-commands-bgx")"; expect "a program that only starts like the background tool asks" deny 1
run "$(bash_json "voice-commands-bg start firefox https://example.org/a")"; expect "background program with a web address" allow 0
run "$(bash_json "voice-commands-bg start firefox https://example.org/a?b=c")"; expect "a ? in an address asks, zsh would treat it as a wildcard" deny 1
run "$(bash_json "voice-commands-bg start firefox https://a.org http://b.org")"; expect "background program with two web addresses" allow 0
run "$(bash_json "voice-commands-bg start firefox file://$H/.ssh/id_ed25519")"; expect "a local file for a background program asks" deny 1
run "$(bash_json "voice-commands-bg start firefox $H/.ssh/id_ed25519")"; expect "a path for a background program asks" deny 1
run "$(bash_json "voice-commands-bg start chromium --renderer-cmd-prefix=x")"; expect "an option for a background program asks" deny 1
run "$(bash_json "voice-commands-bg start firefox 'https://a.org'")"; expect "a quoted address asks" deny 1
run "$(bash_json "voice-commands-bg start {blender,--python,x.py}")"; expect "braces that the shell turns into arguments ask" deny 1
run "$(bash_json "voice-commands-bg start firefox https://a.org/{x,y}")"; expect "braces in an address ask" deny 1
run "$(bash_json 'voice-commands-bg start fire\fox')"; expect "a backslash for a background program asks" deny 1
run "$(bash_json 'voice-commands-bg "start" blender --python x.py')"; expect "a quoted start word asks" deny 1
run "$(bash_json "voice-commands-bg st''art blender --python x.py")"; expect "a start word with empty quotes asks" deny 1
run "$(bash_json "voice-commands-bg start [b]lender")"; expect "a wildcard as the program asks" deny 1
run "$(bash_json "voice-commands-bg start firefox https://a.org/*")"; expect "a wildcard in an address asks" deny 1
run "$(bash_json "voice-commands-bg type hello world")"; expect "typing into a background program" allow 0
run "$(bash_json "date")"; expect "system information without asking" allow 0
run "$(bash_json "df -h")"; expect "system information with options" allow 0
run "$(bash_json "date > $H/x")"; expect "redirection asks" deny 1
run "$(bash_json "date -f.env")"; expect "system information reading .env through an option asks" deny 1
run "$(bash_json "date --file=.env")"; expect "system information with --file=.env asks" deny 1
run "$(bash_json "grep -f.env x Rezepte")"; expect "a file command reading .env through an option asks" deny 1
run "$(bash_json "grep -rn Kuchen Rezepte")"; expect "a file command with short options" allow 0
run "$(bash_json "ls")"; expect "ls in the working folder" allow 0
run "$(bash_json "cat Rezepte/Kuchen.md")"; expect "cat of a file in the working folder" allow 0
run "$(bash_json "ls $H/Documents")"; expect "ls outside the reach asks" deny 1
run "$(bash_json "ls" "$H")"; expect "ls with the current folder outside the reach asks" deny 1
run "$(bash_json "cat keys/id_ed25519")"; expect "cat through a link to ~/.ssh asks" deny 1
run "$(bash_json "find . -delete")"; expect "find with -delete asks" deny 1 "$DELETES"
run "$(bash_json "rm -rf Rezepte")"; expect "rm asks with a warning" deny 1 "$DELETES"
run "$(bash_json "sudo pacman -Syu")"; expect "sudo asks with a warning" deny 1 "$ADMIN"
run "$(bash_json "rm x")" yes; expect "rm, yes is yes" allow 1
run "$(tool Bash '{"command":"curl example.org","description":"Load the page"}')"; expect "Claude's description is shown" deny 1 "Load the page"

settings '{"commands_off":["date","ls"]}'
run "$(bash_json "date")"; expect "system information turned off asks" deny 1
run "$(bash_json "ls")"; expect "file command turned off asks" deny 1

settings '{"file_command_scopes":{"cat":"home","grep":"home"}}'
run "$(bash_json "cat $H/Documents/letter.txt")"; expect "cat with reach home" allow 0
run "$(bash_json "cat $H/.ssh/id_ed25519")"; expect "cat with reach home still asks for ~/.ssh" deny 1
run "$(bash_json "grep -r x $H")"; expect "grep through all of home asks" deny 1
run "$(bash_json "cat $H/Documents/*")"; expect "a wildcard that zsh with globdots expands to a hidden .env asks" deny 1
settings '{"file_command_scopes":{"cat":"everywhere"}}'
run "$(bash_json "cat $H/.ss#h/*")"; expect "a zsh extendedglob pattern asks" deny 1
run "$(bash_json "cat $H/.ss^x/*")"; expect "a zsh negation pattern asks" deny 1

settings '{"own_commands":[{"text":"lsblk","on":true},{"text":"git status","on":true},{"text":"rg","on":true}]}'
run "$(bash_json "lsblk -f")"; expect "own command" allow 0
run "$(bash_json "git status")"; expect "own command with arguments" allow 0
run "$(bash_json "git push")"; expect "other arguments than the own command ask" deny 1
run "$(bash_json "git status" "$H/.ssh")"; expect "own command in a folder with secrets asks" deny 1
run "$(bash_json "lsblk $H/.ssh/id_ed25519")"; expect "own command naming a secret file asks" deny 1
run "$(bash_json "rg x")"; expect "own reading program in the working folder" allow 0
run "$(bash_json "rg x $H/Documents")"; expect "own reading program outside its reach asks" deny 1
no_settings

echo "== Programs the background display refuses"
# Launcher entries, so that only the list of refused programs can refuse them
mkdir -p "$H/.local/share/applications"
# Each entry starts a stub that exists, so that a missing program cannot be the reason for the refusal
mkdir -p "$T/refused"
for program in emacs code kate dolphin nautilus thunar; do
    printf '#!/bin/sh\n' >"$T/refused/$program"; chmod +x "$T/refused/$program"
    printf '[Desktop Entry]\nType=Application\nName=%s\nExec=%s %%F\n' "$program" "$T/refused/$program" \
        >"$H/.local/share/applications/test-$program.desktop"
done
for program in emacs code kate dolphin nautilus thunar; do
    out="$(env -i PATH="$PATH" HOME="$H" XDG_RUNTIME_DIR="$RUN" timeout 20 "$REPO/bin/voice-commands-bg" start "$program" 2>&1)"
    rc=$?
    result "voice-commands-bg refuses $program" "$([ "$rc" = 3 ] && [[ "$out" == Refused* ]] || echo "exit $rc: $out")"
done
printf '[Desktop Entry]\nType=Application\nName=Viewer\nExec=/usr/bin/testviewer\n' >"$H/.local/share/applications/test-viewer.desktop"
out="$(env -i PATH="$PATH" HOME="$H" XDG_RUNTIME_DIR="$RUN" timeout 20 "$REPO/bin/voice-commands-bg" start "$T/testviewer" 2>&1)"
result "voice-commands-bg refuses a path instead of a program name" "$([ $? = 3 ] && [[ "$out" == *path* ]] || echo "$out")"
# The launcher entry decides what runs, not a file of the same name earlier in PATH
mkdir -p "$T/apps" "$T/decoy"
printf '#!/bin/sh\n' >"$T/apps/realviewer"; cp "$T/apps/realviewer" "$T/decoy/realviewer"; chmod +x "$T/apps/realviewer" "$T/decoy/realviewer"
printf '[Desktop Entry]\nType=Application\nName=Real\nExec=%s %%U\n' "$T/apps/realviewer" >"$H/.local/share/applications/test-real.desktop"
program="$(env -i PATH="$T/decoy:$PATH" HOME="$H" bash -c '
    eval "$(sed -n "/^NEVER_PROGRAMS=(/,/^)/p; /^allowed_program() {/,/^}\$/p" "$1")"
    allowed_program realviewer && printf "%s" "$PROGRAM"' _ "$REPO/bin/voice-commands-bg")"
result "the program from the launcher entry runs, not one earlier in PATH" "$([ "$program" = "$T/apps/realviewer" ] || echo "would run: $program")"
out="$(env -i PATH="$PATH" HOME="$H" XDG_RUNTIME_DIR="$RUN" timeout 20 "$REPO/bin/voice-commands-bg" start bash 2>&1)"
result "voice-commands-bg refuses a program without a launcher entry" "$([ $? = 3 ] || echo "$out")"

list_of() { sed -n '/^SECRET_PLACES=(/,/^)/p' "$1" | sed '1d;$d' | tr -s ' \n' '\n\n' | sed '/^$/d' | sort; }
result "the background display hides the same secret places the hook knows" \
    "$(diff <(list_of "$HOOK") <(list_of "$REPO/bin/voice-commands-bg") >/dev/null || echo "SECRET_PLACES differ")"
result "the secret places list is not empty" "$([ "$(list_of "$HOOK" | wc -l)" -gt 20 ] || echo "list not found")"

echo "== The protected area of background programs"
SKIPPED=0
if command -v bwrap >/dev/null && bwrap --dev-bind / / --overlay-src "$H" --tmp-overlay "$H" true 2>/dev/null; then
    # sandboxed SCRIPT: runs SCRIPT with sh in the protected area that voice-commands-bg builds
    sandboxed() {
        env -i PATH="$PATH" HOME="$H" XDG_CONFIG_HOME="$H/.config" XDG_RUNTIME_DIR="$RUN" bash -c '
            WORK="$HOME/Voice-Commands"; STATE="$XDG_RUNTIME_DIR/voice-commands-bg"; mkdir -p "$STATE"
            eval "$(sed -n "/^SECRET_PLACES=(/,/^)/p; /^sandbox_args() {/,/^}\$/p; /^shared_write_args() {/,/^}\$/p" "$1")"
            sandbox_args || exit 9
            timeout 20 bwrap "${SANDBOX[@]}" -- sh -c "$2"' _ "$REPO/bin/voice-commands-bg" "$1" 2>&1
    }
    echo original >"$H/.bashrc"
    mkdir -p "$RUN/voice-commands/grants"
    no_settings
    inside="$(sandboxed '
            echo changed >>~/.bashrc; mkdir -p ~/.config/autostart; touch ~/.config/autostart/x.desktop
            echo kept >~/Voice-Commands/Downloads/kept.txt
            touch $XDG_RUNTIME_DIR/voice-commands/grants/42 2>/dev/null && echo grant-written
            echo ssh=$(ls -A ~/.ssh | wc -l); echo procs=$(ls -d /proc/[0-9]* | wc -l)
            echo runtime=$(ls -A $XDG_RUNTIME_DIR | wc -l); echo bus=${DBUS_SESSION_BUS_ADDRESS:-none}
            echo x11=$(ls -A /tmp/.X11-unix | grep -v "^X77$" | wc -l)
            grep ^XDG_DOWNLOAD_DIR= ~/.config/user-dirs.dirs')"
    result "inside, ~/.ssh is empty" "$([[ "$inside" == *ssh=0* ]] || echo "$inside")"
    procs="$(sed -n 's/^procs=//p' <<<"$inside")"
    result "inside, other processes are hidden" "$([ -n "$procs" ] && [ "$procs" -lt 20 ] || echo "$procs processes, outside $(ls -d /proc/[0-9]* | wc -l)")"
    result "inside, the runtime folder is empty" "$([[ "$inside" == *runtime=0* ]] || echo "$inside")"
    result "inside, the session bus is out of reach" "$([[ "$inside" == *bus=none* ]] || echo "$inside")"
    result "inside, only the invisible X display is there" "$([[ "$inside" == *x11=0* ]] || echo "$inside")"
    result "inside, the grant file cannot be written" "$([[ "$inside" != *grant-written* ]] && [ ! -e "$RUN/voice-commands/grants/42" ] || echo written)"
    result "inside, downloads go to the working folder" "$([[ "$inside" == *"XDG_DOWNLOAD_DIR=\"$W/Downloads\""* ]] || echo "$inside")"
    result "a change to .bashrc stays inside" "$([ "$(cat "$H/.bashrc")" = original ] || echo changed)"
    result "an autostart entry stays inside" "$([ ! -e "$H/.config/autostart/x.desktop" ] || echo written)"
    result "a file in the working folder is kept" "$([ -f "$W/Downloads/kept.txt" ] || echo missing)"
    # Shared folders: one for changing with a Git project, one for reading only, the home folder, ~/.config
    mkdir -p "$H/Shared/proj/.git/hooks" "$H/ReadOnly"
    settings "$(jq -nc --arg s "$H/Shared" --arg r "$H/ReadOnly" --arg h "$H" --arg c "$H/.config" \
        '{folders:[{path:$s, write:true}, {path:$r, write:false}, {path:$h, write:true}, {path:$c, write:true}]}')"
    sandboxed '
            echo a >~/Shared/a.txt; touch ~/Shared/proj/.git/hooks/pre-commit 2>/dev/null
            echo b >~/ReadOnly/b.txt; echo changed >>~/.bashrc; mkdir -p ~/.config/autostart
            touch ~/.config/autostart/y.desktop; echo fake >>~/.local/share/voice-commands/antworten.jsonl' >/dev/null
    result "a folder shared for changing is written for real" "$([ -f "$H/Shared/a.txt" ] || echo missing)"
    result "the history is not written for real, even with a shared home" "$([ ! -s "$H/.local/share/voice-commands/antworten.jsonl" ] || echo written)"
    result "Git hooks in a shared folder stay read only" "$([ ! -e "$H/Shared/proj/.git/hooks/pre-commit" ] || echo written)"
    result "a folder shared for reading only is not written" "$([ ! -e "$H/ReadOnly/b.txt" ] || echo written)"
    result "a shared home folder is not written for real" "$([ "$(cat "$H/.bashrc")" = original ] || echo changed)"
    result "a shared hidden folder is not written for real" "$([ ! -e "$H/.config/autostart/y.desktop" ] || echo written)"
    no_settings
    rm -rf -- "$RUN/voice-commands" "$H/.bashrc" "$H/Shared/a.txt"
else
    SKIPPED=1
    echo "skipped: bubblewrap or the kernel module overlay is not available (sudo modprobe overlay)"
fi

echo "== Other tools"
for t in WebSearch WebFetch ToolSearch TodoWrite TaskCreate; do
    run "$(tool "$t" '{}')"; expect "$t without asking" allow 0
done
run "$(tool mcp__claude_ai_Google_Drive__search_files '{"query":"Steuer"}')"; expect "a connected service asks" deny 1 "Google Drive"
run "$(tool SomethingNew '{"a":1}')"; expect "an unknown tool asks" deny 1 "SomethingNew"

echo "== All permissions for one request"
TASK=42
G="$(grants 42)"
run "$(read_json "$H/Documents/letter.txt")" no; expect "with a task, the window offers all permissions" deny 1 "Give all permissions"
run "$(read_json "$H/Documents/letter.txt")" extra yes
expect "all permissions after the confirmation" allow 2 "Warning: Give all permissions?"
result "the grant is saved" "$([ -f "$G" ] || echo "no file $G")"
run "$(read_json "/etc/hostname")"; expect "with the grant, no more questions" allow 0
run "$(bash_json "rm -rf /tmp/x")"; expect "with the grant, commands too" allow 0
run "$(read_json "$H/.ssh/id_ed25519")"; expect "with the grant, secrets still ask" deny 1 "$SECRETS"
result "secrets do not offer all permissions" "$(! grep -qF -- "--extra-button" "$T/calls" || echo offered)"
rm -rf -- "$RUN/voice-commands"
run "$(read_json "$H/Documents/letter.txt")" extra no no
expect "\"Back\" returns to the question, then no" deny 3
result "no grant after Back" "$([ ! -e "$G" ] || echo "grant saved")"
run "$(read_json "$H/Documents/letter.txt")" extra no yes; expect "\"Back\", then yes for this one" allow 3
result "no grant after Back and yes" "$([ ! -e "$G" ] || echo "grant saved")"
run "$(read_json "$H/Documents/letter.txt")" extra fail; expect "a failing confirmation is no" deny 2
result "no grant after a failing confirmation" "$([ ! -e "$G" ] || echo "grant saved")"
run "$(read_json "$H/Documents/letter.txt")" extra no extra no extra no
expect "three times Back ends with no" deny 6
TASK=43
run "$(read_json "/etc/hostname")"; expect "another task has no grant" deny 1
TASK="../42"
mkdir -p "$RUN/voice-commands/grants" && : >"$RUN/voice-commands/42"
run "$(read_json "/etc/hostname")"; expect "a task name with a path is ignored" deny 1
result "a task name with a path offers nothing" "$(! grep -qF -- "--extra-button" "$T/calls" || echo offered)"
TASK=42
mkdir -p "$RUN/voice-commands/grants" && : >"$RUN/voice-commands/grants/42"
out="$(printf '%s' "$(read_json "/etc/hostname")" | env -i PATH="$PATH" HOME="$H" XDG_CONFIG_HOME="$H/.config" \
    LANG=C VOICE_COMMANDS_DIALOG="$T/dialog" VOICE_COMMANDS_TASK=42 timeout 20 "$HOOK" 2>/dev/null)"
result "without a private runtime folder, a grant counts for nothing" \
    "$([ "$(jq -r .hookSpecificOutput.permissionDecision <<<"$out")" = deny ] || echo "$out")"
rm -rf -- "$RUN/voice-commands"
TASK=""
run "$(read_json "/etc/hostname")"; expect "without a task, no grant" deny 1
result "without a task, all permissions are not offered" "$(! grep -qF -- "--extra-button" "$T/calls" || echo offered)"
rm -rf -- "$RUN/voice-commands"

echo "== Language"
LANGUAGE=de_DE.UTF-8
run "$(read_json "$H/.ssh/id_ed25519")"; expect "German questions" deny 1 "Voice Commands: Erlaubnis"
LANGUAGE=C

echo "== Warnings when sharing a folder in the settings"
# Only this function of the response window is loaded, so that the test needs no GTK
share() {
    python3 -I - "$REPO/bin/voice-commands-window" "$1" <<'PY'
import ast, os, sys
tree = ast.parse(open(sys.argv[1], encoding="utf-8").read())
code = ast.Module([node for node in tree.body if getattr(node, "name", "") == "share_warning"], [])
space = {"os": os}
exec(compile(code, sys.argv[1], "exec"), space)
print(space["share_warning"](sys.argv[2], "/home/jo"))
PY
}
for item in /:root /home/jo:wide /home:wide /opt:wide /boot:wide /tmp:wide /etc/NetworkManager:wide /var/lib:wide \
        /mnt:wide /run/media:wide /home/jo/.config:hidden /home/jo/Dokumente:None /mnt/usb:None /run/media/jo/Stick:None; do
    got="$(share "${item%:*}")"
    result "sharing ${item%:*} gives ${item##*:}" "$([ "$got" = "${item##*:}" ] || echo "got $got")"
done

echo
echo "$PASS passed, $FAIL failed$([ "$SKIPPED" = 0 ] || echo ", protected area skipped")"
[ "$FAIL" -eq 0 ]
