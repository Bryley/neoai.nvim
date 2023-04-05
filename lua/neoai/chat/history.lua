local chat = require("neoai.chat")

---Generates appropriate prompt using data, TODO make this function editable in
---the config
---@param msg string
---@return string
local function gen_prompt(msg)
    return
        "Hi ChatGPT, I'd like to provide some context for future messages. " ..
        "Here is the code/text that I want to refer to in our upcoming " ..
        "conversations:\n\n" .. msg
end

---@class ChatHistory
local ChatHistory = { messages = {} }

function ChatHistory:new()
    local obj = {}

    setmetatable(obj, self)
    self.__index = self

    self.messages = {}

    if chat.context ~= nil then
        self:add_message(true, gen_prompt(chat.context))
    end
    return obj
end

---comment
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
