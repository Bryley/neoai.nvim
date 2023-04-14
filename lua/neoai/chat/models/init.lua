
---@class ModelModule
---@field name string
---@field get_current_output fun(): string Get's current output of the model
---@field send_to_model fun(chat_history: ChatHistory, on_stdout_chunk: fun(chunk: string), on_complete: fun(err?: string, output?: string)) Sends chat_history to the model
