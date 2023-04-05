local M = {}

local CUTOFF_LINE_WIDTH = 75

---@type number
M.current_line = nil

---comment
---@param txt string
---@param line number
M.append_to_buffer = function(txt, line)

    local add_lines = function (line, txt)
        vim.api.nvim_buf_set_lines(0, line, line, false, { txt })
    end
    if M.current_line == nil then
        M.current_line = line + 1
        add_lines(line, "")
    end

    local lines = vim.split(txt, "\n", {})
    local lines_length = #lines

    for i, line_txt in ipairs(lines) do
        local current_line_txt = vim.api.nvim_buf_get_lines(0, M.current_line - 1, M.current_line, false)[1]

        if #current_line_txt >= CUTOFF_LINE_WIDTH then
            add_lines(M.current_line, line_txt)
            M.current_line = M.current_line + 1
            goto continue
        end

        vim.api.nvim_buf_set_lines(0, M.current_line-1, M.current_line, false, { current_line_txt .. line_txt })

        if i < lines_length then
            -- Add new line
            add_lines(M.current_line, "")
            M.current_line = M.current_line + 1
        end
        ::continue::
    end
end

return M
