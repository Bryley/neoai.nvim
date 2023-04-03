local ui = require("neoai.ui")

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

M.setup = function()
	setup_colors()
end

---Toggles opening and closing split
---@param value boolean|nil The value to flip
M.toggle = function(value)
	local open = value or (value == nil and ui.split == nil) -- split.winid == nil)
	if open then
		-- Open
		ui.createUI()

		-- ui.appendToOutput("Wow, it worked :O")
		-- ui.appendToOutput("Now what?")
		-- ui.appendToOutput("\nThis is very cool")
	else
		-- Close
		ui.destroyUI()
	end
end

return M
