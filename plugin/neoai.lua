vim.api.nvim_create_user_command("NeoAI", function(opts)
	local opened = require("neoai").toggle(nil)

	if opened and opts.args ~= "" then
		require("neoai.chat").on_prompt_send(opts.args, require("neoai.ui").appendToOutput)
	end
end, {
	nargs = "*",
})

vim.api.nvim_create_user_command("NeoAIContext", function(opts)
    -- Get contents from visual selection
    local context = table.concat(
        vim.api.nvim_buf_get_lines(0, opts.line1-1, opts.line2, false),
        "\n"
    )
    print(context)
    -- TODO NTS: Need to do this, also cleaning up code, Just prepend the context to the chat messages
end, {
	range = "%",
})
