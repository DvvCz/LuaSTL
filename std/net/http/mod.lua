local http = {}

--- Synchronous http request
---@param url string
---@return string?
function http.get(url)
	assert(type(url) == "string", "Expected string url for http.get argument #1")

	local handle = io.popen("powershell -Command (Invoke-WebRequest " .. url .. ").Content", "r")
	if not handle then return end

	local out = handle:read("*a")
	handle:close()

	return out
end

return http