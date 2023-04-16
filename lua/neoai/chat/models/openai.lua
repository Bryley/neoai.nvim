local utils = require("neoai.utils")
local config = require("neoai.config")

---@type ModelModule
local M = {}

M.name = "OpenAI"

local chunks = {}
local raw_chunks = {}
M.get_current_output = function ()
    return table.concat(chunks, "")
end

---@param chunk string
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
M._recieve_chunk = function(chunk, on_stdout_chunk)
    for line in chunk:gmatch("[^\n]+") do
        local raw_json = string.gsub(line, "^data: ", "")

        table.insert(raw_chunks, raw_json)
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
        on_stdout_chunk(path)
        -- append_to_output(path, 0)
        table.insert(chunks, path)
        ::continue::
    end
end

---@param chat_history ChatHistory
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
---@param on_complete fun(err?: string, output?: string) Function to call when model has finished
M.send_to_model = function (chat_history, on_stdout_chunk, on_complete)
	local api_key = os.getenv(config.options.open_api_key_env)

	local data = {
        model = chat_history.model,
		stream = true,
        messages = chat_history.messages
	}
    chunks = {}
    raw_chunks = {}
	utils.exec("curl", {
        "--silent", "--show-error", "--no-buffer", "https://api.openai.com/v1/chat/completions",
		"-H",
		"Content-Type: application/json",
		"-H",
		"Authorization: Bearer " .. api_key,
		"-d",
		vim.json.encode(data),
	}, function (chunk)
        M._recieve_chunk(chunk, on_stdout_chunk)
	end, function (err, _)
        local total_message = table.concat(raw_chunks, "")
        local ok, json = pcall(vim.json.decode, total_message)
        if ok then
            if json.error ~= nil then
                on_complete(json.error.message, nil)
                return
            end
        end
        on_complete(err, M.get_current_output())
    end)
end

return M
