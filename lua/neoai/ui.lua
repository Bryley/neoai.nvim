local Layout = require("nui.layout")
local Split = require("nui.split")
local Popup = require("nui.popup")
local chat = require("neoai.chat")
local ChatHistory = require("neoai.chat.history")

local M = {}

-- Module functions
M.output_popup = nil
M.input_popup = nil
M.split = nil
M.layout = nil

---@param prompt string
M.submit_prompt = function (prompt)
    -- This is an empty function for now and will be replaced
end

M.clear_input = function ()
    if (M.input_popup ~= nil) then
        local buffer = M.input_popup.bufnr
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {})
    end
end

M.createUI = function()
	M.split = Split({
		relative = "editor",
		position = "right",
		size = "20%",
		win_options = {
			relativenumber = false,
			number = false,
		},
	})

	M.output_popup = Popup({
		enter = false,
		focusable = true,
		zindex = 50,
		position = "50%",
		border = {
			style = "rounded",
			text = {
				top = " NeoAI ",
				top_align = "center",
			},
		},
		buf_options = {
			-- modifiable = true,
			-- readonly = false,
		},
		-- win_options = {
		-- 	winblend = 10,
		-- 	winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		-- },
		win_options = {
			wrap = true,
		},
	})

	M.input_popup = Popup({
		enter = true,
		focusable = true,
		zindex = 50,
		position = "50%",
		border = {
			style = "rounded",
			padding = {
				left = 1,
				right = 1,
			},
			text = {
				top = " Prompt ",
				top_align = "center",
			},
		},
		buf_options = {
			modifiable = true,
			readonly = false,
		},
		win_options = {
			winblend = 10,
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
			wrap = true,
		},
	})

	M.layout = Layout(
		M.split,
		Layout.Box({
			Layout.Box(M.output_popup, { size = "80%" }),
			Layout.Box(M.input_popup, { size = "20%" }),
		}, { dir = "col" })
	)
	M.layout:mount()

    chat.chat_history = ChatHistory:new()

    local input_buffer = M.input_popup.bufnr

    M.submit_prompt = function ()
        local lines = vim.api.nvim_buf_get_lines(input_buffer, 0, -1, false)
        local prompt = table.concat(lines, '\n')
        chat.on_prompt_send(prompt, M.appendToOutput)
        M.clear_input()
    end

    local opts = {noremap = true, silent = true}
    vim.api.nvim_buf_set_keymap(input_buffer, "i", "<C-Enter>", "<Enter>", opts)
    vim.api.nvim_buf_set_keymap(input_buffer, "i", "<Enter>", "<cmd>lua require('neoai.ui').submit_prompt()<cr>", opts)

end

M.destroyUI = function()
	M.layout:unmount()
	M.split:unmount()
	M.split = nil
	M.layout = nil
    M.submit_prompt = function ()
        -- Empty function
    end
    chat.chat_history = nil
end

-- TODO NTS: Now want to do some colors for user and response also putting result in
-- register
-- Also alow for back and forth converstations and having a visual selection range as well

---Append text to the output, GPT should populate this
---@param txt string The text to append to the UI
---@param type number 0/nil = normal, 1 = input
M.appendToOutput = function(txt, type)
	local lines = vim.split(txt, "\n", {})

    local ns = vim.api.nvim_get_namespaces().neoai_output

    if ns == nil then
        ns = vim.api.nvim_create_namespace("neoai_output")
    end

    local hl = "Normal"
    if type == 1 then
        -- hl = "NeoAIInput"
        hl = "ErrorMsg"
    end

    local length = #lines

    if M.output_popup == nil then
        vim.api.nvim_err_writeln("NeoAI window needs to be open")
        return
    end
    local buffer = M.output_popup.bufnr
    local win = M.output_popup.winid

	for i, line in ipairs(lines) do

        local currentLine = vim.api.nvim_buf_get_lines(buffer, -2, -1, false)[1]
        vim.api.nvim_buf_set_lines(buffer, -2, -1, false, {currentLine .. line})

		-- local last_line_num = vim.api.nvim_buf_line_count(buffer)
		-- local last_line = vim.api.nvim_buf_get_lines(buffer, last_line_num - 1, last_line_num, false)[1]
		-- local new_text = last_line .. line


		-- vim.api.nvim_buf_set_lines(buffer, last_line_num - 1, last_line_num, false, { new_text })
        local last_line_num = vim.api.nvim_buf_line_count(buffer)
        -- vim.api.nvim_buf_add_highlight(buffer, ns, hl, last_line_num - 1, 0, -1)

		if i < length then
			-- Add new line
			vim.api.nvim_buf_set_lines(buffer, -1, -1, false, { "" })
		end
        vim.api.nvim_win_set_cursor(win, {last_line_num, 0})
	end
end

return M
-- Rplace me

