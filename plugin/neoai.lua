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

-- Versions of the commands that use vim.ui.input for retrieving the prompt/context
-- Plain
vim.api.nvim_create_user_command("NeoAIPrompt", function(_)
	vim.ui.input({ prompt = "Prompt: " }, function(text)
		require("neoai").smart_toggle(text)
	end)
end, {
	nargs = 0,
})

-- Context
vim.api.nvim_create_user_command("NeoAIContextPrompt", function(opts)
	vim.ui.input({ prompt = "Context: " }, function(text)
		require("neoai").context_smart_toggle(text, opts.line1, opts.line2)
	end)
end, {
	nargs = 0,
	range = "%",
})

-- Inject
vim.api.nvim_create_user_command(
	"NeoAIInjectPrompt",
	function(_)
		vim.ui.input({ prompt = "Prompt: " }, function(text)
			require("neoai").inject(text)
		end)
	end,
	{
		nargs = 0,
	}
)

vim.api.nvim_create_user_command(
	"NeoAIInjectCodePrompt",
	function(_)
		vim.ui.input({ prompt = "Prompt: " }, function(text)
			require("neoai").inject(text, require('neoai.utils').extract_code_snippets)
		end)
	end,
	{
		nargs = 0,
	}
)

vim.api.nvim_create_user_command(
	"NeoAIInjectContextPrompt",
	function(opts)
		vim.ui.input({ prompt = "Context: " }, function(text)
			require("neoai").context_inject(text, nil, opts.line1, opts.line2)
		end)
	end,
	{
		range = "%",
		nargs = 0,
	}
)

vim.api.nvim_create_user_command(
	"NeoAIInjectContextCodePrompt",
	function(opts)
		vim.ui.input({ prompt = "Context: " }, function(text)
			require("neoai").context_inject(text, require('neoai.utils').extract_code_snippets, opts.line1, opts.line2)
		end)
	end,
	{
		range = "%",
		nargs = 0,
	}
)
