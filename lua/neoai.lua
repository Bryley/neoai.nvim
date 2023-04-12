local ui = require("neoai.ui")
local chat = require("neoai.chat")
local inject = require("neoai.inject")
local ChatHistory = require("neoai.chat.history")
local config = require("neoai.config")

local M = {}

local function setup_colors()
	local hl_group_name = "NeoAIInput"
	local color = { guifg = "#61afef"}
	vim.api.nvim_command(
		"highlight "
			.. hl_group_name
			.. " guifg="
			.. color.guifg
	)
end

---Setup NeoAI
---@param options Options | nil
M.setup = function(options)
	-- setup_colors()
    config.setup(options)
end

---Toggles opening and closing split
---@param value boolean|nil The value to flip
---@return boolean true if opened and false if closed
M.toggle = function(value)
	local open = value or (value == nil and not ui.is_open())
	if open then
		-- Open
		ui.create_ui()
        return true
	else
		-- Close
		ui.destroy_ui()
        return false
	end
end

M.toggle_with_args = function (args)
    local opened = M.toggle(nil)

    if opened and args ~= "" then
        ui.send_prompt(args)
    end
end


M.focus_toggle = function (args)
    local send_args = function ()
        if args ~= "" then
            ui.send_prompt(args)
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

M.inject = function (prompt, strip_function)
    chat.chat_history = ChatHistory:new()

    strip_function = strip_function or function (x)
        return x
    end

    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_create_augroup("NeoAIInjectGroup", {})
    chat.on_prompt_send(prompt, function (txt, _)
        local txt1 = strip_function(chat.get_current_output())
        local txt2 = strip_function(table.concat({chat.get_current_output(), txt}, ""))

        inject.append_to_buffer(string.sub(txt2, #txt1 + 1), current_line)
    end, false, function (output)
        inject.current_line = nil
        vim.api.nvim_out_write("Done generating AI response\n")
        vim.api.nvim_del_augroup_by_name("NeoAIInjectGroup")
    end)
end

return M
