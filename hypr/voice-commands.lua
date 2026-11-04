-- Voice Commands: keyboard shortcuts and window rule.
-- The shortcuts can be changed in the settings of the response window, which writes them to
-- ~/.config/voice-commands/shortcuts.lua. A shortcut that does not work shows a warning.
local keys = { toggle = "SUPER + G", cancel = "SUPER + SHIFT + G", window = "SUPER + ALT + G",
               send = "SUPER + CTRL + G", type = "SUPER + I" }
local config = os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or "") .. "/.config")
local found, custom = pcall(dofile, config .. "/voice-commands/shortcuts.lua")
if found and type(custom) == "table" then
    for action, combo in pairs(custom) do
        if keys[action] and type(combo) == "string" and combo ~= "" then keys[action] = combo end
    end
end

-- The loader names the folder of the programs, which is a copy of the source in development mode
local bin = VOICE_COMMANDS_BIN or "/usr/bin"
local commands = {
    toggle = bin .. "/voice-commands toggle",
    cancel = bin .. "/voice-commands cancel",
    window = bin .. "/voice-commands-window",
    send = bin .. "/voice-commands send",
    type = bin .. "/voice-commands-input",
}
local failed = {}
for _, action in ipairs({ "toggle", "cancel", "window", "send", "type" }) do
    local ok, bound = pcall(hl.bind, keys[action], hl.dsp.exec_cmd(commands[action]))
    if not ok or not bound then failed[#failed + 1] = keys[action] end
end
if #failed > 0 then
    local de = (os.getenv("LC_ALL") or os.getenv("LC_MESSAGES") or os.getenv("LANG") or ""):sub(1, 2) == "de"
    hl.notification.create({ timeout = 20000, color = "rgba(e5a50aff)", text = de
        and ("Voice Commands: Diese Tastenkürzel funktionieren nicht: " .. table.concat(failed, ", ") .. ". Ändere sie in den Einstellungen des Antwortfensters.")
        or ("Voice Commands: These keyboard shortcuts do not work: " .. table.concat(failed, ", ") .. ". Change them in the settings of the response window.") })
end

hl.window_rule({ match = { class = "^(local\\.voicecommands\\.VoiceCommands)$" }, float = true, center = true })
-- Input window for typed commands
hl.window_rule({ match = { class = "^(local\\.voicecommands\\.VoiceCommands\\.Input)$" }, float = true, center = true })
-- Permission windows of Voice Commands
hl.window_rule({ match = { class = "^(local\\.voicecommands\\.VoiceCommands\\.Ask)$" }, float = true, center = true })
