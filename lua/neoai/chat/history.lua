local chat = require("neoai.chat")
local config = require("neoai.config")

---@class ChatHistory
local ChatHistory = { messages = {} }

function ChatHistory:new()
    local obj = {}

    setmetatable(obj, self)
    self.__index = self

    self.messages = {}

    if chat.context ~= nil then
        local prompt = config.options.prompts.context_prompt(chat.context)
        self:add_message(true, prompt)
    end
    return obj
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
