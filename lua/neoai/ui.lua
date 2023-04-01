
local Layout = require("nui.layout")
local Split = require("nui.split")
local Popup = require("nui.popup")

local M = {}

M.split = nil
M.layout = nil

M.createUI = function ()
    M.split = Split({
        relative = "editor",
        position = "right",
        size = "20%",
        win_options = {
            relativenumber = false,
            number = false,
        },
    })

    local output_popup = Popup({
        enter = false,
        focusable = true,
        zindex = 50,
        position = "50%",
        border = {
            style = "rounded",
            text = {
                top = " I am top title ",
                top_align = "center",
            },
        },
        buf_options = {
            modifiable = false,
            readonly = true,
        },
        -- win_options = {
        -- 	winblend = 10,
        -- 	winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        -- },
    })

    local input_popup = Popup({
        enter = true,
        focusable = true,
        zindex = 50,
        position = "50%",
        border = {
            style = "rounded",
            padding = {
                left = 1,
                right = 1,
            },
            text = {
                top = " I am top title ",
                top_align = "center",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = false,
        },
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
            wrap = true,
        },
    })

    M.layout = Layout(
        M.split,
        Layout.Box({
            Layout.Box(output_popup, { size = "80%" }),
            Layout.Box(input_popup, { size = "20%" }),
        }, { dir = "col" })
    )
	M.layout:mount()
end

M.destroyUI = function ()
    M.layout:unmount()
    M.split:unmount()
    M.split = nil
    M.layout = nil
end

return M
