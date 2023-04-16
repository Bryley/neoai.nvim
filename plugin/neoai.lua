-- Plain GUI

vim.api.nvim_create_user_command("NeoAI", function(opts)
	require("neoai").smart_toggle(opts.args)
end, {
	nargs = "*",
})

vim.api.nvim_create_user_command("NeoAIToggle", function(opts)
	require("neoai").toggle(opts.args)
end, {
	nargs = "*",
})

vim.api.nvim_create_user_command("NeoAIOpen", function(opts)
	require("neoai").toggle(true, opts.args)
end, {
	nargs = "*",
})

vim.api.nvim_create_user_command("NeoAIClose", function()
	require("neoai").toggle(false)
end, {})

-- Context GUI

vim.api.nvim_create_user_command("NeoAIContext", function(opts)
	require("neoai").context_smart_toggle(opts.args, opts.line1, opts.line2)
end, {
	range = "%",
	nargs = "*",
})

vim.api.nvim_create_user_command("NeoAIContextOpen", function(opts)
	require("neoai").context_toggle(true, opts.args, opts.line1, opts.line2)
end, {
	range = "%",
	nargs = "*",
})

vim.api.nvim_create_user_command("NeoAIContextClose", function()
	require("neoai").context_toggle(false, "", nil, nil)
end, {})

-- Inject Mode

vim.api.nvim_create_user_command("NeoAIInject", function(opts)
	require("neoai").inject(opts.args)
end, {
	nargs = "+",
})

vim.api.nvim_create_user_command("NeoAIInjectCode", function(opts)
	local extract_code_snippets = require("neoai.utils").extract_code_snippets
	require("neoai").inject(opts.args, extract_code_snippets)
end, {
	nargs = "+",
})

vim.api.nvim_create_user_command("NeoAIInjectContext", function(opts)
	require("neoai").context_inject(opts.args, nil, opts.line1, opts.line2)
end, {
	range = "%",
	nargs = "+",
})

vim.api.nvim_create_user_command("NeoAIInjectContextCode", function(opts)
	local extract_code_snippets = require("neoai.utils").extract_code_snippets
	require("neoai").context_inject(opts.args, extract_code_snippets, opts.line1, opts.line2)
end, {
	range = "%",
	nargs = "+",
})

vim.api.nvim_create_user_command("NeoAIShortcut", function (opts)
    local mode
    if opts.range == 0 then
        mode = "n"
    else
        mode = "v"
    end
    local shortcut_name = opts.fargs[1]
    local func = require("neoai.shortcuts").shortcut_functions[shortcut_name .. mode]
    if func == nil then
        vim.notify("Shortcut '" .. shortcut_name .. "' doesn't support '" .. mode .. "' mode", vim.log.levels.ERROR)
        return
    end
    func()
end, {
    nargs = 1,
    range = true,
    complete = require("neoai.shortcuts").complete_shortcut
})
