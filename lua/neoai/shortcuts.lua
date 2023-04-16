local config = require("neoai.config")

local M = {}

---@type table<string, fun()>
M.shortcut_functions = {}

---@param raw_prompt string | fun(): string The raw prompt supplied by the user
local generate_prompt = function(raw_prompt)
    ---@type string
    local prompt
    if type(raw_prompt) == "string" then
        prompt = raw_prompt
    else
        prompt = raw_prompt()
    end

    -- prompt = string.gsub(prompt, "\n", "\\n")
    -- prompt = string.gsub(prompt, "%s+", " ")
    prompt = string.gsub(prompt, " +", " ")
    return prompt
end


M.setup_shortcuts = function()
    local opts = { silent = false, noremap = true }

    for index, shortcut in ipairs(config.options.shortcuts) do
        for _, mode in ipairs(shortcut.modes) do
            local unique_id = shortcut.name or ("__uid" .. index)
            unique_id = unique_id .. mode
            if mode == "v" then
                M.shortcut_functions[unique_id] = function()
                    local prompt = generate_prompt(shortcut.prompt)
                    require("neoai").context_inject(prompt, shortcut.strip_function)
                end
            end
            if mode == "n" then
                M.shortcut_functions[unique_id] = function()
                    local prompt = generate_prompt(shortcut.prompt)
                    require("neoai").context_inject(prompt, shortcut.strip_function, 0, vim.fn.line("$"))
                end
            end
            opts.desc = shortcut.desc
            local cmd = "<esc><cmd>lua require('neoai.shortcuts').shortcut_functions['" .. unique_id .. "']()<cr>"
            if shortcut.key ~= nil then
                -- TODO change to this because it is easier
                -- vim.keymap.set(mode, shortcut.key, cmd, opts)
                vim.api.nvim_set_keymap(mode, shortcut.key, cmd, opts)
            end
        end
    end
end

M.complete_shortcut = function(arg_lead, _, _)
    local results = {}
    local shortcuts = require("neoai.shortcuts").shortcut_functions

    for key, _ in pairs(shortcuts) do
        if string.sub(key, 1, #arg_lead) == arg_lead then
            local new_key = string.sub(key, 1, (#key - 1))
            table.insert(results, new_key)
        end
    end

    return results
end

return M
