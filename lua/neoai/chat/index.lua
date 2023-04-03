local ui = require("neoai.ui")
local utils = require("neoai.utils")

local M = {}

local chunks = {}

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
		ui.appendToOutput(path, 0)
        table.insert(chunks, path)
		::continue::
	end
end

---@param prompt string
M.on_prompt_send = function(prompt)
	ui.appendToOutput(prompt .. "\n--------\n", 1)
    chunks = {}
	M.send_chat(prompt, recieve_chunk, function(err, _)
		if err ~= nil then
			vim.api.nvim_err_writeln("Recieved OpenAI error: " .. err)
			return
		end
		ui.appendToOutput("\n--------\n", 1)
        utils.save_to_register(table.concat(chunks, ""))
	end)
end
--@param prompt string
--@param on_stdout_chunk fun(chunk: string)
--@param on_complete(err?: string, output?: string):nil
M.send_chat = function(prompt, on_stdout_chunk, on_complete)
	local api_key = os.getenv("OPENAI_API_KEY")
	local data = {
		model = "gpt-3.5-turbo",
		stream = true,
		messages = {
			{
				role = "user",
				content = prompt,
			},
		},
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
