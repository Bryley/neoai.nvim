local utils = require("neoai.utils")
local ChatHistory = require("neoai.chat.history")

local M = {}

M.chat_history = ChatHistory:new()
local append_to_output = nil

local chunks = {}

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
M.on_prompt_send = function(prompt, append_to_output_func)
    append_to_output = append_to_output_func
	append_to_output(prompt .. "\n--------\n", 1)
    chunks = {}
	M.send_chat(prompt, recieve_chunk, function(err, _)
		if err ~= nil then
			vim.api.nvim_err_writeln("Recieved OpenAI error: " .. err)
			return
		end
		append_to_output("\n--------\n", 1)
        local output = table.concat(chunks, "")
        utils.save_to_register(output)
        M.chat_history:add_message(false, output)
	end)
end

--@param prompt string
--@param on_stdout_chunk fun(chunk: string)
--@param on_complete(err?: string, output?: string):nil
M.send_chat = function(prompt, on_stdout_chunk, on_complete)
	local api_key = os.getenv("OPENAI_API_KEY")

    M.chat_history:add_message(true, prompt)

	local data = {
		model = "gpt-3.5-turbo",
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
