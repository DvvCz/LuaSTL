---@class Test
---@field name string
---@field __start fun(state: table)?
---@field __stop fun(state: table)?
---@field cases { [1]: string, [2]: fun(state: table) }[]
local Test = {}
Test.__index = Test

---@param name string
function Test.new(name)
	return setmetatable({ name = name, cases = {} }, Test)
end

function Test:__newindex(k, v)
	if type(k) == "string" and k:sub(1, 5) == "test_" then
		if type(v) == "function" then
			self.cases[#self.cases + 1] = { k, v }
		end
		-- Ignore non-function
	else
		rawset(self, k, v)
	end
end

function Test:run()
	local state = {}
	if self.__start then
		self.__start(state)
	end

	local failures, cases = {}, #self.cases
	for _, case in ipairs(self.cases) do
		local name, fn = case[1], case[2]
		local ok, res = pcall(fn, state)
		if not ok then
			failures[#failures + 1] = "Case '" .. name .. "' : " .. tostring(res)
		end
	end

	if self.__stop then
		self.__stop(state)
	end

	if #failures > 0 then
		print("TEST '" .. self.name .. "' FAILED " .. #failures .. " / " .. cases .. " CASES")
		print("\t" .. table.concat(failures, "\n\t"))
	else
		print("TEST '" .. self.name .. "' PASSED " .. cases .. " CASES")
	end
end

return {
	Test = Test
}