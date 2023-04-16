local config = require("neoai.config")

---@class ChatHistory
---@field model string The name of the model
---@field messages { role: "user" | "assistant", content: string }[] The message history
local ChatHistory = { model = "", messages = {} }

---Create new chat history object
---@param model string The model to use
---@param context string | nil The context to use
---@return ChatHistory
function ChatHistory:new(model, context)
    local obj = {}

    setmetatable(obj, self)
    self.__index = self

    self.model = model
    self.messages = {}

    if context ~= nil then
        local context_prompt = config.options.prompts.context_prompt(context)
        self:set_prompt(context_prompt)
    end
    return obj
end

--- @param prompt string system prompt
function ChatHistory:set_prompt(prompt)
    local system_msg = {
        role = "system",
        content = prompt,
    }
    table.insert(self.messages, system_msg)
end

---@param user boolean True if user sent msg
---@param msg string The message to add
function ChatHistory:add_message(user, msg)
    local role = user and "user" or "assistant"

    table.insert(self.messages, {
        role = role,
        content = msg,
    })
end

return ChatHistory
