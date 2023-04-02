local utils = require("neoai.utils")

local M = {}

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
