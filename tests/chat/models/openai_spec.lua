local M = require("lua.neoai.chat.models.openai")
local config = require("neoai.config")
local utils = require("neoai.utils")
local assert = require("luassert")
local stub = require("luassert.stub")

describe("OpenAI Module", function()
    describe("send_to_model", function()
        it("should call on_stdout_chunk with correct content", function()
            local chat_history = {
                model = "test_model",
                messages = {}
            }

            local on_stdout_chunk_called = false
            local on_stdout_chunk = function(chunk)
                assert.is_true(chunk == "Hello World")
                on_stdout_chunk_called = true
            end

            local on_complete_called = false
            local on_complete = function(err, _)
                assert.is_nil(err)
                on_complete_called = true
            end

            config.options.open_api_key_env = "INVALID_API_KEY"

            -- Mock os.getenv function to return a dummy API key
            local getenv_stub = stub(os, "getenv", function(_)
                return "dummy_api_key"
            end)

            -- Use luassert.stub to mock the utils.exec function
            local exec_stub = stub(utils, "exec", function(_, _, on_stdout, on_exit)
                local input_chunk = 'data: {"id":"test","choices":[{"delta":{"content":"Hello World"}}]}'
                on_stdout(input_chunk) -- Call on_stdout directly with the input_chunk
                on_exit(nil, nil)
            end)

            M.send_to_model(chat_history, on_stdout_chunk, on_complete)

            -- Verify the exec_stub and getenv_stub were called and then revert the stubs
            assert.stub(exec_stub).was.called()
            assert.stub(getenv_stub).was.called()
            exec_stub:revert()
            getenv_stub:revert()

            assert.is_true(on_complete_called)
            assert.is_true(on_stdout_chunk_called)
        end)
    end)

    describe("get_current_output", function()
        it("should return concatenated output", function()
            M.chunks = { "Hello", " World" }
            local output = M.get_current_output()
            assert.is_true(output == "Hello World")
        end)
    end)
end)
