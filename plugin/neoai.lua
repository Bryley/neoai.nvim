
vim.api.nvim_create_user_command("NeoAI", function ()
    require("neoai").toggle(nil)
end, {})
