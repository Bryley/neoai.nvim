local Layout = require("nui.layout")
local Split = require("nui.split")
local Popup = require("nui.popup")
local utils = require("neoai.utils")

local M = {}

M.output_popup = nil
M.input_popup = nil
M.split = nil
M.layout = nil

---@param prompt string
M.submit_prompt = function (prompt)
    -- This is an empty function for now
end

M.clear_input = function ()
    if (M.input_popup ~= nil) then
        local buffer = M.input_popup.bufnr
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {})
    end
end

M.createUI = function(on_prompt_send)
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
				top = " I am top title ",
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
				top = " I am top title ",
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

    local input_buffer = M.input_popup.bufnr

    M.submit_prompt = function ()
        local lines = vim.api.nvim_buf_get_lines(input_buffer, 0, -1, false)
        local prompt = table.concat(lines, '\n')
        on_prompt_send(prompt)
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
end


-- TODO NTS: Fix multiple newlines together eg '\n\n' doesn't work correctly
-- Also now want to do some colors for user and response also putting result in
-- register

---Append text to the output, GPT should populate this
---@param txt string The text to append to the UI
M.appendToOutput = function(txt)
	local lines = utils.split_string_at_newline(txt)

	for i, line in ipairs(lines) do
		if M.output_popup == nil then
			vim.api.nvim_err_writeln("NeoAI window needs to be open")
			return
		end
		local buffer = M.output_popup.bufnr

		local last_line_num = vim.api.nvim_buf_line_count(buffer)

		local last_line = vim.api.nvim_buf_get_lines(buffer, last_line_num - 1, last_line_num, false)[1]

		local new_text = last_line .. line

		vim.api.nvim_buf_set_lines(buffer, last_line_num - 1, last_line_num, false, { new_text })
		if i < #lines - 1 then
			-- Add new line
			vim.api.nvim_buf_set_lines(buffer, last_line_num, last_line_num, false, { "" })
		end
	end
end

return M
