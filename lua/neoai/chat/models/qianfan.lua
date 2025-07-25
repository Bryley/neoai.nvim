local utils = require("neoai.utils")
local config = require("neoai.config")

---@type ModelModule
local M = {}

M.name = "Qianfan"

M._chunks = {}
local raw_chunks = {}

M.get_current_output = function()
    return table.concat(M._chunks, "")
end

---@param chunk string
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
M._recieve_chunk = function(chunk, on_stdout_chunk)
    local raw_json = chunk

    table.insert(raw_chunks, raw_json)

    local ok, path = pcall(vim.json.decode, raw_json)
    if not ok then
        return
    end

    path = path.result
    if path == nil then
        return
    end

    on_stdout_chunk(path)
    -- append_to_output(path, 0)
    table.insert(M._chunks, path)
end

---@param chat_history ChatHistory
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
---@param on_complete fun(err?: string, output?: string) Function to call when model has finished
M.send_to_model = function(chat_history, on_stdout_chunk, on_complete)
    local secret, apikey  = config.options.qianfan.api_key.get()
    local model = config.options.models[config.options.selected_model_index+1].model

    local get_script_dir = function()
        local info = debug.getinfo(1, "S")
        local script_path  = info.source:sub(2)
        return script_path:match("(.*/)")
    end

    local py_script_path = get_script_dir() .. "qianfan.py"

    os.execute("chmod +x "..py_script_path)

    chunks = {}
    raw_chunks = {}
    utils.exec(py_script_path, {
        apikey,
        secret,
        vim.json.encode(chat_history.messages),
        model,
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
