local M = {}

---Get default options
---@return Options
M.get_defaults = function()
    return {
        ui = {
            output_popup_text = "NeoAI",
            input_popup_text = "Prompt",
            width = 30,      -- As percentage eg. 30%
            output_popup_height = 80, -- As percentage eg. 80%
        },
        models = {
            {
                name = "openai",
                model = "gpt-3.5-turbo"
            },
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
                return "Hey, I'd like to provide some context for future "
                    .. "messages. Here is the code/text that I want to refer "
                    .. "to in our upcoming conversations (TEXT/CODE ONLY):\n\n"
                    .. context
            end,
        },
        open_api_key_env = "OPENAI_API_KEY",
        shortcuts = {
            {
                key = "<leader>as",
                use_context = true,
                prompt = [[
                    Please rewrite the text to make it more readable, clear,
                    concise, and fix any grammatical, punctuation, or spelling
                    errors
                ]],
                modes = { "v" },
                strip_function = nil,
            },
            {
                key = "<leader>ag",
                use_context = false,
                prompt = function ()
                    return [[
                        Using the following git diff generate a consise and
                        clear git commit message, with a short title summary
                        that is 75 characters or less:
                    ]] .. vim.fn.system("git diff --cached")
                end,
                modes = { "n" },
                strip_function = nil,
            },
        },
    }
end

---@class UI_Options
---@field output_popup_text string Header text shown on output popup window
---@field input_popup_text string Header text shown on input popup window
---@field width integer The width of the window as a percentage number 30 = 30%
---@field output_popup_height integer The height of the output popup as a percentage

---@class Model_Options
---@field name "openai" The name of the model provider
---@field model string | string[] The name of the model to use or list of model names to use

---@class Inject_Options
---@field cutoff_width integer | nil When injecting if the text becomes longer than this then it should go to a new line, if nil then ignore

---@class Prompt_Options
---@field context_prompt fun(context: string) string Prompt to generate the prompt that should be used when using Context modes

---@class Shortcut
---@field key string The key bind value to listen for
---@field use_context boolean If the context from the selection/buffer should be used
---@field prompt string|fun(): string The prompt to send or a function to generate the prompt to send
---@field modes ("n" | "v")[] A list of modes to set the keybind up for "n" for normal, "v" for visual
---@field strip_function (fun(output: string): string) | nil The strip function to use

---@class Options
---@field ui UI_Options UI configurations
---@field model string The OpenAI model to use by default @depricated
---@field models Model_Options[] A list of different model options to use. First element will be default
---@field register_output table<string, fun(output: string): string> A table with a register as the key and a function that takes the raw output from the AI and outputs what you want to save into that register
---@field inject Inject_Options The inject options
---@field prompts Prompt_Options The custom prompt options
---@field open_api_key_env string The environment variable that contains the openai api key
---@field shortcuts Shortcut[] Array of shortcuts
M.options = {}

---Setup options
---@param options Options | nil
M.setup = function(options)
    options = options or {}
    M.options = vim.tbl_deep_extend("force", {}, M.get_defaults(), options)
end

return M
