local openai_model = require("lua.neoai.chat.models.openai")
local config = require("neoai.config")
local ChatHistory = require("neoai.chat.history")
local utils = require("neoai.utils")
local assert = require("luassert")
local stub = require("luassert.stub")

describe("OpenAI Module", function()
    describe("send_to_model", function()
        it("should call on_stdout_chunk with correct content", function()

            -- Setup the config module to use the test config
            -- TODO: Should be better way to do this
            config.setup()
            -- Mock os.getenv function to return a dummy API key
            local getenv_stub = stub(os, "getenv", function(_)
                return "dummy_api_key"
            end)

            local chat_history = ChatHistory:new("test_model", {}, "test_context")

            local on_stdout_chunk_called = false
            local on_stdout_chunk = function(chunk)
                assert.equal("Hello World", chunk)
                on_stdout_chunk_called = true
            end

            local on_complete_called = false
            local on_complete = function(err, _)
                assert.is_nil(err)
                on_complete_called = true
            end


            -- Use luassert.stub to mock the utils.exec function
            local exec_stub = stub(utils, "exec", function(_, _, on_stdout, on_exit)
                local input_chunk = 'data: {"id":"test","choices":[{"delta":{"content":"Hello World"}}]}'
                on_stdout(input_chunk) -- Call on_stdout directly with the input_chunk
                on_exit(nil, nil)
            end)

            openai_model.send_to_model(chat_history, on_stdout_chunk, on_complete)

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
            openai_model._chunks = { "Hello", " World" }
            local expected = "Hello World"
            local output = openai_model.get_current_output()
            assert.equal(expected, output)
        end)
    end)
end)
