local ui = require("neoai.ui")
local chat = require("neoai.chat")
local inject = require("neoai.inject")
local ChatHistory = require("neoai.chat.history")
local config = require("neoai.config")
local shortcuts = require("neoai.shortcuts")

local M = {}

---Sets the context
---@param line1 integer | nil The first line number to use, nil will use '<
---@param line2 integer | nil The second line number to use, nil will use '>
---@return integer, integer line1 and line2
local set_context = function (line1, line2)
    local buffer = vim.api.nvim_get_current_buf()

    line1 = line1 or vim.fn.line("'<")
    line2 = line2 or vim.fn.line("'>")

    chat.set_context(buffer, line1, line2)

    return line1, line2
end

-- TODO
local function setup_colors()
    local hl_group_name = "NeoAIInput"
    local color = { guifg = "#61afef" }
    vim.api.nvim_command("highlight " .. hl_group_name .. " guifg=" .. color.guifg)
end

---Setup NeoAI given options
---@param options Options | nil The options for the plugin
M.setup = function(options)
    config.setup(options)
    chat.setup_models()
    shortcuts.setup_shortcuts()
end

---Toggles opening and closing neoai window
---@param toggle boolean | nil If true will open GUI and false will close, nil will toggle
---@param prompt string | nil If set then this prompt will be sent to the GUI if toggling on
---@return boolean true if opened and false if closed
M.toggle = function(toggle, prompt)
    local open = toggle or (toggle == nil and not ui.is_open())
    if open then
        -- Open
        ui.create_ui()
        if prompt ~= nil then
            ui.send_prompt(prompt)
        end
        return true
    else
        -- Close
        ui.destroy_ui()
        return false
    end
end

---Smart focus, if closed then will open on GUI, if opened and focused then it
---will close GUI and if opened and not focused then it will focus on the GUI.
---@param prompt string The prompt to inject, to inject no prompt just do empty string
M.smart_toggle = function(prompt)
    local send_args = function()
        if prompt ~= "" then
            ui.send_prompt(prompt)
        end
    end
    if ui.is_open() then
        if ui.is_focused() then
            M.toggle(false)
        else
            ui.focus()
            send_args()
        end
    else
        M.toggle(true)
        send_args()
    end
end

---Toggles the GUI in Context mode
---@param toggle boolean | nil True will force open, False will force close, nil will toggle
---@param prompt string The prompt to inject into the GUI if any (otherwise specify an empty string)
---@param line1 integer | nil The first line number for context range otherwise will use visual selection
---@param line2 integer | nil The second line number for context range otherwise will use visual selection
---@return boolean True if was opened
M.context_toggle = function (toggle, prompt, line1, line2)
    set_context(line1, line2)
    return M.toggle(toggle, prompt)
end

---Smart toggles context GUI
---@param prompt string The prompt to inject into the GUI if any (otherwise specify an empty string)
---@param line1 integer | nil The first line number for context range otherwise will use visual selection
---@param line2 integer | nil The second line number for context range otherwise will use visual selection
M.context_smart_toggle = function (prompt, line1, line2)
    set_context(line1, line2)
    M.smart_toggle(prompt)
end

---Sends prompt and injects the response straight back into the buffer without
---opening the GUI
---@param prompt string The prompt to send to the AI
---@param strip_function (fun(output: string): string) | nil A function that strips the output
---@param start_line integer | nil The line to start injecting onto (After inserting 2 newlines), nil = current selected line
M.inject = function(prompt, strip_function, start_line)
    chat.new_chat_history()

    strip_function = strip_function or function(x)
        return x
    end

    local current_line = start_line or vim.api.nvim_win_get_cursor(0)[1]
    chat.send_prompt(
        prompt,
        function(txt, _)
            -- Get differences between text
            local txt1 = strip_function(chat.get_current_output())
            local txt2 = strip_function(table.concat({ chat.get_current_output(), txt }, ""))

            inject.append_to_buffer(string.sub(txt2, #txt1 + 1), current_line)
        end,
        false,
        function(_)
            inject.current_line = nil
            vim.notify("NeoAI: Done generating AI response", vim.log.levels.INFO)
        end
    )
end

---Same as inject except uses a context
---@param prompt string The prompt to send to the AI
---@param strip_function (fun(output: string): string) | nil A function that strips the output
---@param line1 integer | nil The first line num in the range if nil will use '<
---@param line2 integer | nil The second line num in the range if nil will use '>
M.context_inject = function(prompt, strip_function, line1, line2)
    line1, line2 = set_context(line1, line2)
    M.inject(prompt, strip_function, line2)
end

return M
