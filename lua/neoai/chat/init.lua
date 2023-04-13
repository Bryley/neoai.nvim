local utils = require("neoai.utils")
local config = require("neoai.config")

local M = {}

---@type string
M.context = nil

---@type ChatHistory
M.chat_history = nil
local append_to_output = nil


---@param buffer number
---@param line1 number
---@param line2 number
M.set_context = function (buffer, line1, line2)
    local context = table.concat(vim.api.nvim_buf_get_lines(buffer, line1 - 1, line2, false), "\n")
    M.chat_history = nil
    M.context = context
end

M.reset = function ()
    M.context = nil
    M.chat_history = nil
end

local chunks = {}

M.get_current_output = function ()
    return table.concat(chunks, "")
end

---@param chunk string
local recieve_chunk = function(chunk)
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
		append_to_output(path, 0)
        table.insert(chunks, path)
		::continue::
	end
end

---@param prompt string
---@param append_to_output_func function
---@param separators boolean True if separators should be included
---@param on_complete function Called when completed
M.on_prompt_send = function(prompt, append_to_output_func, separators, on_complete)
    append_to_output = append_to_output_func
    if separators then
        append_to_output(prompt .. "\n\n--------\n\n", 1)
    end
    chunks = {}
	M.send_chat(prompt, recieve_chunk, function(err, _)
		if err ~= nil then
			vim.api.nvim_err_writeln("Recieved OpenAI error: " .. err)
			return
		end
        if separators then
            append_to_output("\n\n--------\n\n", 1)
        end
        local output = table.concat(chunks, "")
        M.chat_history:add_message(false, output)
        on_complete(output)
	end)
end

---@param prompt string
---@param on_stdout_chunk fun(chunk: string)
---@param on_complete fun(err?: string, output?: string):nil
M.send_chat = function(prompt, on_stdout_chunk, on_complete)
	local api_key = os.getenv(config.options.open_api_key_env)

    M.chat_history:add_message(true, prompt)

	local data = {
        model = config.options.model,
		stream = true,
        messages = M.chat_history.messages
		-- messages = {
		-- 	{
		-- 		role = "user",
		-- 		content = prompt,
		-- 	},
		-- },
	}
	utils.exec("curl", {
        "--silent", "--show-error", "--no-buffer",
		"https://api.openai.com/v1/chat/completions",
		"-H",
		"Content-Type: application/json",
		"-H",
		"Authorization: Bearer " .. api_key,
		"-d",
		vim.json.encode(data),
	}, on_stdout_chunk, on_complete)
end

return M
