local env = require "std.env.mod"

local http = {}

local internal_get
if env.consts.OS == "Unix" then
	function internal_get(url)
		assert(type(url) == "string", "Expected string url for http.get argument #1")

		local handle = io.popen(string.format("curl %q", url), "r")
		if not handle then return end

		local out = handle:read("*a")
		handle:close()

		return out
	end
else
	function internal_get(url)
		assert(type(url) == "string", "Expected string url for http.get argument #1")

		local handle = io.popen(string.format("powershell -Command (Invoke-WebRequest %q).Content", url), "r")
		if not handle then return end

		local out = handle:read("*a")
		handle:close()

		return out
	end
end

--- Synchronous http request
---@param url string
---@return string?
function http.get(url)
	assert(type(url) == "string", "Expected string url for http.get argument #1")
	return internal_get(url)
end

return http