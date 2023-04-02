local ui = require("neoai.ui")
local chat = require("neoai.chat")

local M = {}

local recieve_chunk = function(chunk)
	-- response['choices'][0]['message']['content']
	-- ui.appendToOutput("'" .. string.gsub(chunk, "^data: ", "") .. "'" .. '\n\n\n')

	for line in chunk:gmatch("[^\n]+") do
		local raw_json = string.gsub(line, "^data: ", "")

		local ok, path = pcall(vim.json.decode, raw_json)
		if not ok then
            goto continue
		end

        path = path.choices
        if path == nil then
            goto continue
        end
        path = path[1]
        if path == nil then
            goto continue
        end
        path = path.delta
        if path == nil then
            goto continue
        end
        path = path.content
        if path == nil then
            goto continue
        end
        ui.appendToOutput(path)
	    ::continue::
	end

	-- local path = parsed_data.choices
	-- if path == nil then
	-- 	ui.appendToOutput("1")
	-- 	return
	-- end
	-- path = path[1]
	-- if path == nil then
	-- 	ui.appendToOutput("2")
	-- 	return
	-- end
	-- path = path.delta
	-- if path == nil then
	-- 	ui.appendToOutput("3")
	-- 	return
	-- end
	-- path = path.content
	-- if path == nil then
	-- 	ui.appendToOutput("4")
	-- 	return
	-- end
	--
	-- ui.appendToOutput("Below:\n")
	-- ui.appendToOutput(path)
end

---@param prompt string
local on_prompt_send = function(prompt)
    ui.appendToOutput(prompt .. "\n")
	chat.send_chat(prompt, recieve_chunk, function(err, out)
		if err ~= nil then
			vim.api.nvim_err_writeln("Recieved OpenAI error: " .. err)
			return
		end
		ui.appendToOutput("\nDone")
	end)
end

---Toggles opening and closing split
---@param value boolean|nil The value to flip
M.toggleSplit = function(value)
	local open = value or (value == nil and ui.split == nil) -- split.winid == nil)
	if open then
		-- Open
		ui.createUI(on_prompt_send)

		-- ui.appendToOutput("Wow, it worked :O")
		-- ui.appendToOutput("Now what?")
		-- ui.appendToOutput("\nThis is very cool")
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
