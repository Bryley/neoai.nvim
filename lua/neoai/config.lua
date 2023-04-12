local M = {}

---Get default options
---@return Options
M.get_defaults = function()
	return {
		ui = {
			output_popup_text = "NeoAI",
			input_popup_text = "Prompt",
			width = 30, -- As percentage eg. 30%
			output_popup_height = 80, -- As percentage eg. 80%
		},
		register_output = {
			["g"] = function(output)
				return output
			end,
			["c"] = require("neoai.utils").extract_code_snippets,
		},
		inject = {
			cutoff_width = 75,
		},
		prompts = {
			context_prompt = function(context)
				return "Hi ChatGPT, I'd like to provide some context for future "
                    .. "messages. Here is the code/text that I want to refer "
                    .. "to in our upcoming conversations:\n\n"
					.. context
			end,
		},
        open_api_key_env = "OPENAI_API_KEY",
	}
end

---@class UI_Options
---@field output_popup_text string Header text shown on output popup window
---@field input_popup_text string Header text shown on input popup window
---@field width integer The width of the window as a percentage number 30 = 30%
---@field output_popup_height integer The height of the output popup as a percentage

---@class Inject_Options
---@field cutoff_width integer | nil When injecting if the text becomes longer than this then it should go to a new line, if nil then ignore

---@class Prompt_Options
---@field context_prompt fun(context: string) string Prompt to generate the prompt that should be used when using Context modes

---@class Options
---@field ui UI_Options UI configurations
---@field register_output table<string, fun(output: string): string> A table with a register as the key and a function that takes the raw output from the AI and outputs what you want to save into that register
---@field inject Inject_Options The inject options
---@field prompts Prompt_Options The custom prompt options
---@field open_api_key_env string The environment variable that contains the openai api key
M.options = {}

---Setup options
---@param options Options | nil
M.setup = function(options)
	options = options or {}
	M.options = vim.tbl_deep_extend("force", {}, M.get_defaults(), options)
end

return M
