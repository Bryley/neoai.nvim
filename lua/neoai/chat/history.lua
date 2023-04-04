
---@class ChatHistory
local ChatHistory = { messages = {} }

function ChatHistory:new()
    local obj = {}

    setmetatable(obj, self)
    self.__index = self

    self.messages = {}
    return obj
end


---comment
---@param user boolean True if user sent msg
---@param msg string The message to add
---@return ChatHistory
function ChatHistory:add_message(user, msg)
    local role = user and "user" or "assistant"

    table.insert(self.messages, {
        role = role,
        content = msg,
    })
end

return ChatHistory
