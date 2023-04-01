
local event = require("nui.utils.autocmd").event
local Layout = require("nui.layout")
local Popup = require("nui.popup")

local ui = require("neoai.ui")

local M = {}


---Toggles opening and closing split
---@param value boolean|nil The value to flip
M.toggleSplit = function(value)
	local open = value or (value == nil and ui.split == nil)-- split.winid == nil)
	if open then
		-- Open
        ui.createUI()
	else
		-- Close
        ui.destroyUI()
	end
end

M.test = function()
	-- split:mount()
	-- print(split.winid)
	--
	-- local main_popup = Popup({
	-- 	enter = false,
	-- 	focusable = true,
	-- 	zindex = 50,
	-- 	position = "50%",
	-- 	border = {
	-- 		style = "rounded",
	-- 		text = {
	-- 			top = " I am top title ",
	-- 			top_align = "center",
	-- 		},
	-- 	},
	-- 	buf_options = {
	-- 		modifiable = false,
	-- 		readonly = true,
	-- 	},
	-- 	-- win_options = {
	-- 	-- 	winblend = 10,
	-- 	-- 	winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
	-- 	-- },
	-- })
	-- local popup2 = Popup({
	-- 	enter = true,
	-- 	focusable = true,
	-- 	zindex = 50,
	-- 	position = "50%",
	-- 	border = {
	-- 		style = "rounded",
	-- 		padding = {
	-- 			left = 1,
	-- 			right = 1,
	-- 		},
	-- 		text = {
	-- 			top = " I am top title ",
	-- 			top_align = "center",
	-- 		},
	-- 	},
	-- 	buf_options = {
	-- 		modifiable = true,
	-- 		readonly = false,
	-- 	},
	-- 	win_options = {
	-- 		winblend = 10,
	-- 		winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
	-- 		wrap = true,
	-- 	},
	-- })
	--
	-- local layout = Layout(
	-- 	{
	-- 		position = "50%",
	-- 		relative = {
	-- 			type = "win",
	-- 			winid = split.winid,
	-- 		},
	-- 		size = {
	-- 			width = "90%",
	-- 			height = "90%",
	-- 		},
	-- 	},
	-- 	Layout.Box({
	-- 		Layout.Box(main_popup, { size = "80%" }),
	-- 		Layout.Box(popup2, { size = "20%" }),
	-- 	}, { dir = "col" })
	-- )

	-- layout:mount()
	--
	-- main_popup:on({ event.BufDelete, event.WinClosed }, function()
	-- 	split:unmount()
	-- end, { once = true })
	-- popup2:on({ event.BufDelete, event.WinClosed }, function()
	-- 	split:unmount()
	-- end, { once = true })
	--
	-- split:on({ event.BufDelete, event.WinClosed }, function()
	-- 	layout:unmount()
	-- end, { once = true })

	-- popup.mount()
	-- print(split.bufnr)

	-- layout:mount()
	-- split:mount()

	-- print(tostring(vim.api.nvim_buf_get_option(0, 'number')))

	-- for key, value in pairs(vim.api.nvim_get_all_options_info()) do
	--     if key == "number" then
	--         print(key)
	--         for k, v in pairs(value) do
	--             print(k .. " | " .. tostring(v))
	--         end
	--     end
	-- end

	-- print("Option: " .. vim.api.nvim_win_get_option(0, 'filetype'))
	-- print("Option: " .. vim.api.nvim_buf_get_option(0, "filetype"))
	-- print("Hello World")
end

return M
