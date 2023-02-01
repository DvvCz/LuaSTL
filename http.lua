local http = {}

--- Synchronous http request
---@param url string
---@return string
function http.get(url)
	assert(type(url) == "string", "Expected string url for HTTP.Get argument #1")

	local handle = io.popen("powershell -Command (Invoke-WebRequest " .. url .. ").Content", "r")
		local out = handle:read("*a")
	handle:close()

	return out
end

return http