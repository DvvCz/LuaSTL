local env = {
	---@type { PATH_SEPARATOR: "/" | "\\", OS: "Unix" | "Windows" }
	consts = {}
}

env.var = os.getenv

env.consts.PATH_SEPARATOR = package.config:sub(1, 1)

--- Hopefully this will have better narrowing in the future.
env.consts.OS = env.consts.PATH_SEPARATOR == "\\" and "Windows" or "Unix"

return env