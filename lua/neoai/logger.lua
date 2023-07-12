--- Logger module for NeoAI
-- @module neoai.logger

local M = {}

M.deprecation = function(what, instead)
    vim.notify(what .. " is deprecated, use " .. instead, vim.log.levels.WARN, {
        title = "NeoAI",
    })
end

M.debug = function(message)
    vim.notify(message, vim.log.levels.DEBUG, {
        title = "NeoAI",
    })
end

M.info = function(message)
    vim.notify(message, vim.log.levels.INFO, {
        title = "NeoAI",
    })
end

M.warning = function(message)
    vim.notify(message, vim.log.levels.WARN, {
        title = "NeoAI",
    })
end

M.error = function(message)
    vim.notify(message, vim.log.levels.ERROR, {
        title = "NeoAI",
    })
end

return M
