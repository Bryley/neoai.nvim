

local M = {}


---@param text string
---@return string
M.extract_code_snippets = function (text)
	local matches = {}
	for match in string.gmatch(text, "```%w*\n(.-)```") do
		table.insert(matches, match)
	end
	return table.concat(matches, "\n\n")
end


---@param output string
M.save_to_registers = function(output)
    vim.fn.setreg("g", output)
    vim.fn.setreg("c", M.extract_code_snippets(output))
end

---Executes command getting stdout chunks
---@param cmd string
---@param args string[]
---@param on_stdout_chunk fun(chunk: string): nil
---@param on_complete fun(err: string?, output: string?): nil
function M.exec (cmd, args, on_stdout_chunk, on_complete)
    local stdout = vim.loop.new_pipe()
    local function on_stdout_read (_, chunk)
        if chunk then
            vim.schedule(function ()
                on_stdout_chunk(chunk)
            end)
        end
    end

    local stderr = vim.loop.new_pipe()
    local stderr_chunks = {}
    local function on_stderr_read (_, chunk)
        if chunk then
            table.insert(stderr_chunks, chunk)
        end
    end

    local handle

    handle, error = vim.loop.spawn(cmd, {
        args = args,
        stdio = {nil, stdout, stderr},
    }, function (code)
        stdout:close()
        stderr:close()
        handle:close()

        vim.schedule(function ()
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


return M
