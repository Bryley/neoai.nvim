
vim.api.nvim_create_user_command("Test", function ()
    require("neoai").test()
end, {})

vim.api.nvim_create_user_command("Test2", function ()
    require("neoai").toggleSplit(nil)
end, {})
