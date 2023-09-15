local utils = require("neoai.utils")
local config = require("neoai.config")

---@type ModelModule
local M = {}

M.name = "Spark"

M._chunks = {}
local raw_chunks = {}

M.get_current_output = function()
    return table.concat(M._chunks, "")
end

---@param chunk string
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
M._recieve_chunk = function(chunk, on_stdout_chunk)
    for line in chunk:gmatch("[^\n]+") do
        local raw_json = line

        table.insert(raw_chunks, raw_json)

        local ok, path = pcall(vim.json.decode, raw_json)
        if not ok then
            goto continue
        end

        path = path.payload
        if path == nil then
            goto continue
        end

        path = path.choices
        if path == nil then
            goto continue
        end

        path = path.text
        if path == nil then
            goto continue
        end

        path = path[1]
        if path == nil then
            goto continue
        end

        path = path.content
        if path == nil then
            goto continue
        end


        on_stdout_chunk(path)
        -- append_to_output(path, 0)
        table.insert(M._chunks, path)
        ::continue::
    end
end

---@param chat_history ChatHistory
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
---@param on_complete fun(err?: string, output?: string) Function to call when model has finished
M.send_to_model = function(chat_history, on_stdout_chunk, on_complete)
    local appid, secret, apikey  = config.options.spark.api_key.get()
    local ver = config.options.spark.version
    local random_threshold = config.options.spark.random_threshold
    local max_tokens = config.options.spark.max_tokens

    local get_script_dir = function()
        local info = debug.getinfo(1, "S")
        local script_path  = info.source:sub(2)
        return script_path:match("(.*/)")
    end

    local py_script_path = get_script_dir() .. "spark.py"

    os.execute("chmod +x "..py_script_path)

    chunks = {}
    raw_chunks = {}
    utils.exec(py_script_path, {
        appid,
        secret,
        apikey,
        vim.json.encode(chat_history.messages),
        "--ver",
        ver,
        "--random_threshold",
        random_threshold,
        "--max_tokens",
        max_tokens
    }, function(chunk)
        M._recieve_chunk(chunk, on_stdout_chunk)
    end, function(err, _)
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
