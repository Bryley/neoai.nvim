local logger = require("neoai.logger")
---@class Config
---@field options Options
---@field setup function
---@field get_defaults function
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
            submit = "<Enter>",
        },
        selected_model_index = 0,
        models = {
            {
                name = "openai",
                model = "gpt-3.5-turbo",
                params = nil,
            },
            {
                name = "spark",
                model = "v1",
                params = nil,
            }
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
        mappings = {
            ["select_up"] = "<C-k>",
            ["select_down"] = "<C-j>",
        },
        open_ai = {
            api_key = {
                env = "OPENAI_API_KEY",
                value = nil,
                get = function()
                    local open_api_key = nil
                    if M.options.open_ai.api_key.value then
                        open_api_key = M.options.open_ai.api_key.value
                    else
                        local env_name
                        if M.options.open_api_key_env then
                            env_name = M.options.open_api_key_env
                            logger.deprecation("config.open_api_key_env", "config.open_ai.api_key.env")
                        else
                            env_name = M.options.open_ai.api_key.env
                        end
                        open_api_key = os.getenv(env_name)
                    end

                    if open_api_key then
                        return open_api_key
                    end
                    local msg = M.options.open_ai.api_key.env
                    .. " environment variable is not set, and open_api_key.value is empty"
                    logger.error(msg)
                    error(msg)
                end,
            },
        },
        spark = {
            random_threshold = 0.5,
            max_tokens = 4096,
            version = "v1",
            api_key = {
                appid_env = "SPARK_APPID",
                secret_env = "SPARK_SECRET",
                apikey_env = "SPARK_APIKEY",
                appid = nil,
                secret = nil,
                apikey = nil,
                get = function()
                    if not M.options.spark.api_key.appid then
                        M.options.spark.api_key.appid = os.getenv(M.options.spark.api_key.appid_env)
                    end
                    if not M.options.spark.api_key.secret then
                        M.options.spark.api_key.secret = os.getenv(M.options.spark.api_key.secret_env)
                    end
                    if not M.options.spark.api_key.apikey then
                        M.options.spark.api_key.apikey = os.getenv(M.options.spark.api_key.apikey_env)
                    end
                    if M.options.spark.api_key.appid and M.options.spark.api_key.secret and M.options.spark.api_key.apikey then
                        return M.options.spark.api_key.appid, M.options.spark.api_key.secret, M.options.spark.api_key.apikey
                    end
                    local msg = M.options.spark.api_key.appid_env .. "/"
                    .. M.options.spark.api_key.secret_env .. "/"
                    .. M.options.spark.api_key.apikey_env .. " environment variable is not set"
                    logger.error(msg)
                    error(msg)
                end
            },
        },
        shortcuts = {
            {
                name = "textify",
                key = "<leader>as",
                desc = "NeoAI fix text with AI",
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
                name = "gitcommit",
                key = "<leader>ag",
                desc = "NeoAI generate git commit message",
                use_context = false,
                prompt = function()
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
---@field submit string The key binding to submit the input

---@class Model_Options
---@field name "openai" The name of the model provider
---@field model string | string[] The name of the model to use or list of model names to use
---@field params table<string, string> | nil Params to pass into the model(s) or nil is none.

---@class Inject_Options
---@field cutoff_width integer | nil When injecting if the text becomes longer than this then it should go to a new line, if nil then ignore

---@class Prompt_Options
---@field context_prompt fun(context: string) string Prompt to generate the prompt that should be used when using Context modes

---@class Shortcut
---@field name string The name of the shortcut, can trigger using :NeoAIShortcut <name>
---@field key string | nil The key bind value to listen for or nil if none
---@field desc string | nil The description of the shortcut
---@field use_context boolean If the context from the selection/buffer should be used
---@field prompt string|fun(): string The prompt to send or a function to generate the prompt to send
---@field modes ("n" | "v")[] A list of modes to set the keybind up for "n" for normal, "v" for visual
---@field strip_function (fun(output: string): string) | nil The strip function to use

---@class Open_AI_Options
---@field api_key Open_AI_Key_Options The open api key options

---@class Open_AI_Key_Options
---@field env string The environment variable to get the open api key from
---@field value string | nil The value of the open api key to use, if nil then use the environment variable
---@field get fun(): string The function to get the open api key

---@class Spark_Options
---@field random_threshold float The random_threshold
---@field max_tokens int The max tokens count
---@field version ("v1" | "v2") The model version
---@field api_key Spark_Key_Options The Spark api key options

---@class Spark_Key_Options
---@field appid_env string The environment variable to get the spark appid
---@field secret_env string The environment variable to get the spark secret
---@field apikey_env string The environment variable to get the spark apikey
---@field appid string The spark appid
---@field secret string The spark secret
---@field apikey string The spark apikey
---@field get fun(): string,string,string The function to get the open api key

---@class Options
---@field ui UI_Options UI configurations
---@field model string The OpenAI model to use by default @depricated
---@field models Model_Options[] A list of different model options to use. First element will be default
---@field selected_model_index int Selected model index (started from zero)
---@field register_output table<string, fun(output: string): string> A table with a register as the key and a function that takes the raw output from the AI and outputs what you want to save into that register
---@field inject Inject_Options The inject options
---@field prompts Prompt_Options The custom prompt options
---@field open_api_key_env string The environment variable that contains the openai api key
---@field open_ai Open_AI_Options The open api key options
---@field spark Spark_Options The Spark api key options
---@field mappings table<"select_up" | "select_down", nil|string|string[]> A table of actions with it's mapping(s)
---@field shortcuts Shortcut[] Array of shortcuts
M.options = {}

---Setup options
---@param options Options | nil
---@return Config
M.setup = function(options)
    options = options or {}
    M.options = vim.tbl_deep_extend("force", {}, M.get_defaults(), options)
    return M
end

return M
