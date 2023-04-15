local config = require("neoai.config")
local M = {}

---@param text string
---@return string
M.extract_code_snippets = function(text)
	local matches = {}
	for match in string.gmatch(text, "```%w*\n(.-)```") do
		table.insert(matches, match)
	end

	-- Next part matches any code snippets that are incomplete
	local count = select(2, string.gsub(text, "```", "```"))
	if count % 2 == 1 then
		local pattern = "```%w*\n([^`]-)$"
		local match = string.match(text, pattern)
		table.insert(matches, match)
	end
	return table.concat(matches, "\n\n")
end

---@param output string
M.save_to_registers = function(output)
    for register, strip_func in pairs(config.options.register_output) do
        vim.fn.setreg(register, strip_func(output))
    end
end

---Executes command getting stdout chunks
---@param cmd string
---@param args string[]
---@param on_stdout_chunk fun(chunk: string): nil
---@param on_complete fun(err: string?, output: string?): nil
function M.exec(cmd, args, on_stdout_chunk, on_complete)
	local stdout = vim.loop.new_pipe()
	local function on_stdout_read(_, chunk)
		if chunk then
			vim.schedule(function()
				on_stdout_chunk(chunk)
			end)
		end
	end

	local stderr = vim.loop.new_pipe()
	local stderr_chunks = {}
	local function on_stderr_read(_, chunk)
		if chunk then
			table.insert(stderr_chunks, chunk)
		end
	end

	local handle

	handle, error = vim.loop.spawn(cmd, {
		args = args,
		stdio = { nil, stdout, stderr },
	}, function(code)
		stdout:close()
		stderr:close()
		handle:close()

		vim.schedule(function()
			if code ~= 0 then
				on_complete(vim.trim(table.concat(stderr_chunks, "")))
			else
				on_complete()
			end
		end)
	end)

	if not handle then
		on_complete(cmd .. " could not be started: " .. error)
	else
		stdout:read_start(on_stdout_read)
		stderr:read_start(on_stderr_read)
	end
end

M.is_empty = function(s)
	return s == nil or s == ""
end

return M
