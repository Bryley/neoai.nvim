local config = require("neoai.config")
local M = {}


---@param text string
---@return string
M.extract_code_snippets = function(text)
	local matches = {}
	for match in string.gmatch(text, "```%w*\n(.-)```") do
		table.insert(matches, match)
	end

	-- Next part matches any code snippets that are incomplete
	local count = select(2, string.gsub(text, "```", "```"))
	if count % 2 == 1 then
		local pattern = "```%w*\n([^`]-)$"
		local match = string.match(text, pattern)
		table.insert(matches, match)
	end
	return table.concat(matches, "\n\n")
end

---@param output string
M.save_to_registers = function(output)
	for register, strip_func in pairs(config.options.register_output) do
		vim.fn.setreg(register, strip_func(output))
	end
end

M.is_empty = function(s)
	return s == nil or s == ""
end


return M
