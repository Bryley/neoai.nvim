local config = require("neoai.config")
local assert = require("luassert")
local stub = require("luassert.stub")
local spy = require("luassert.spy")

local function should_fail(fun)
	local stat = pcall(fun)
	assert(not stat, "Function should fail")
end

describe("Getting OpenAI API key", function()
	describe("with value not set and not existed ENV variable", function()
		it("should fail ", function()
			stub(os, "getenv", function(_)
				return nil
			end)
			local options = config.setup().options
			should_fail(options.open_ai.api_key.get)
		end)
	end)

	describe("with value not set and default ENV variable setting", function()
		it("should return the values of ENV variable)", function()
			local expected_key = "dummy_api_key"
			stub(os, "getenv", function(_)
				return expected_key
			end)

			local options = config.setup().options
			assert.equal(expected_key, options.open_ai.api_key.get())
		end)
	end)

	describe("with value not set and user's ENV variable setting", function()
		it("should return the values of user ENV variable)", function()
			local user_env_key = "user_env_key"
			local expected_key = "dummy_api_key"
			stub(os, "getenv", function(key)
				-- getenv returns nil if the key is not found
				if key == user_env_key then
					return expected_key
				end
			end)

			local options = config.setup({
				open_ai = {
					api_key = {
						env = user_env_key,
					},
				},
			}).options
			assert.equal(expected_key, options.open_ai.api_key.get())
		end)
	end)

	describe("with value set and default ENV variable setting", function()
		it("should return the value", function()
			local expected_key = "dummy_api_key"
			stub(os, "getenv", function(_)
				return "another_dummy_api_key"
			end)

			local options = config.setup({
				open_ai = {
					api_key = {
						value = expected_key,
					},
				},
			}).options
			assert.equal(expected_key, options.open_ai.api_key.get())
		end)
	end)

	describe("with value not set and user's custom 'get' function", function()
		it("should return the value", function()
			local expected_key = "dummy_api_key"

			local options = config.setup({
				open_ai = {
					api_key = {
						get = function()
							return expected_key
						end,
					},
				},
			}).options
			local open_ai_api_key = options.open_ai.api_key.get()
			assert.equal(expected_key, open_ai_api_key)
		end)
	end)
end)
