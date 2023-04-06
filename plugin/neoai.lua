vim.api.nvim_create_user_command("NeoAI", function(opts)
    require("neoai").focus_toggle(opts.args)
    -- require("neoai").toggle_with_args(opts.args)
end, {
    nargs = "*",
})

vim.api.nvim_create_user_command("NeoAIContext", function(opts)
    -- Get contents from visual selection
    local buffer = vim.api.nvim_get_current_buf()
    require("neoai.chat").set_context(buffer, opts.line1, opts.line2)
    require("neoai").toggle_with_args(opts.args)

    -- TODO NTS: Need to do this, also cleaning up code, Just prepend the context to the chat messages
end, {
    range = "%",
    nargs = "*",
})


vim.api.nvim_create_user_command("NeoAIInject", function (opts)
    require("neoai").inject(opts.args, nil)
end, {
    nargs = "+",
})

vim.api.nvim_create_user_command("NeoAIInjectCode", function (opts)
    local extract_code_snippets = require("neoai.utils").extract_code_snippets
    require("neoai").inject(opts.args, extract_code_snippets)
end, {
    nargs = "+",
})


vim.api.nvim_create_user_command("NeoAIInjectContext", function (opts)
    local buffer = vim.api.nvim_get_current_buf()
    require("neoai.chat").set_context(buffer, opts.line1, opts.line2)
    require("neoai").inject(opts.args, nil)
end, {
    range = "%",
    nargs = "+",
})

vim.api.nvim_create_user_command("NeoAIInjectContextCode", function (opts)
    local extract_code_snippets = require("neoai.utils").extract_code_snippets
    local buffer = vim.api.nvim_get_current_buf()
    require("neoai.chat").set_context(buffer, opts.line1, opts.line2)
    require("neoai").inject(opts.args, extract_code_snippets)
end, {
    range = "%",
    nargs = "+",
})
