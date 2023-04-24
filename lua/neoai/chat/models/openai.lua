local config = require("neoai.config")
local curl = require("plenary.curl")
local utils = require("neoai.utils")

---@type ModelModule
local M = {}
M.name = "OpenAI"

local handler
local chunks = {}
local raw_chunks = {}

---@brief Cancel the current stream and shut down the handler
M.cancel_stream = function()
  if handler ~= nil then
    handler:shutdown()
    handler = nil
  end
end

M.get_current_output = function()
	return table.concat(chunks, "")
end

---@param chunk string
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
M._receive_chunk = function(chunk, on_stdout_chunk)
	local function safely_extract_delta_content(decoded_json)
		local path = decoded_json.choices
		if not path then
			return nil
		end

		path = path[1]
		if not path then
			return nil
		end

		path = path.delta
		if not path then
			return nil
		end

		return path.content
	end
	-- Remove "data:" prefix from chunk
	local raw_json = string.gsub(chunk, "%s*data:%s*", "")
	table.insert(raw_chunks, raw_json)

	local ok, decoded_json = pcall(vim.json.decode, raw_json)
	if not ok then
		return -- Ignore invalid JSON chunks
	end

	local delta_content = safely_extract_delta_content(decoded_json)
	if delta_content then
		table.insert(chunks, delta_content)
		on_stdout_chunk(delta_content)
	end
end

---@param chat_history ChatHistory
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
---@param on_complete fun(err?: string, output?: string) Function to call when model has finished
M.send_to_model = function(chat_history, on_stdout_chunk, on_complete)
	local api_key = os.getenv(config.options.open_api_key_env)

	local data = {
		model = chat_history.model,
		stream = true,
		messages = chat_history.messages,
	}
	data = vim.tbl_deep_extend("force", {}, data, chat_history.params)

	chunks = {}
	raw_chunks = {}
	handler = curl.post({
		url = "https://api.openai.com/v1/chat/completions",
		raw = { "--no-buffer" },
		headers = {
			content_type = "application/json",
			Authorization = "Bearer " .. api_key,
		},
		body = vim.json.encode(data),
		stream = function(_, chunk)
			if chunk ~= "" then
				-- The following workaround helps to identify when the model has completed its task.
				if string.match(chunk, "%[DONE%]") then
					vim.schedule(function()
						on_complete(nil, M.get_current_output())
					end)
				else
					vim.schedule(function()
						M._receive_chunk(chunk, on_stdout_chunk)
					end)
				end
			end
		end,
		on_error = function(err, _, _)
			return on_complete(err, nil)
		end,
	})
end

return M
