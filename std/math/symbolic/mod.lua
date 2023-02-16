---@class Equation
---@field variant EquationVariant
---@field data any
local Equation = {}
Equation.__index = Equation

---@param variant EquationVariant
---@param data any
function Equation.new(variant, data)
	return setmetatable({ variant = variant, data = data }, Equation)
end

---@enum EquationVariant
local EquationVariant = {
	Number = -1,
	Symbol = 0,

	Addition = 1,
	Subtraction = 2,
	Multiplication = 3,
	Division = 4,
	Exponentation = 5,

	GreaterThan = 6,
	GreaterThanOrEqual = 7,
	LessThan = 8,
	LessThanOrEqual = 9,

	Negation = 10,

	Sin = 11,
	Cos = 12
}

---@param ident string
function Symbol(ident)
	return setmetatable({ variant = EquationVariant.Symbol, data = ident }, Equation)
end

---@param num number
function Number(num)
	return setmetatable({ variant = EquationVariant.Number, data = num }, Equation)
end

function Equation:__tostring()
	local v, tv = self.variant, EquationVariant
	if v == tv.Number then
		return tostring(self.data)
	elseif v == tv.Symbol then
		return self.data
	elseif v == tv.Addition then
		return string.format("%s + %s", self.data[1], self.data[2])
	elseif v == tv.Subtraction then
		return string.format("%s - %s", self.data[1], self.data[2])
	elseif v == tv.Multiplication then
		return string.format("%s * %s", self.data[1], self.data[2])
	elseif v == tv.Division then
		return string.format("%s / %s", self.data[1], self.data[2])
	elseif v == tv.Negation then
		return string.format("-%s", self.data)
	elseif v == tv.Exponentation then
		return string.format("%s ^ %s", self.data[1], self.data[2])
	elseif v == tv.Sin then
		return string.format("sin(%s)", self.data)
	elseif v == tv.Cos then
		return string.format("cos(%s)", self.data)
	else
		return "Unimplemented: " .. v
	end
end

function Equation.__add(lhs, rhs)
	if type(rhs) == "number" then
		return Equation.new(EquationVariant.Addition, { lhs, Number(rhs) })
	elseif getmetatable(rhs) == Equation then
		return Equation.new(EquationVariant.Addition, { lhs, rhs })
	else
		error("Invalid + operation")
	end
end

function Equation.__sub(lhs, rhs)
	if type(rhs) == "number" then
		return Equation.new(EquationVariant.Subtraction, { lhs, Number(rhs) })
	elseif getmetatable(rhs) == Equation then
		return Equation.new(EquationVariant.Subtraction, { lhs, rhs })
	else
		error("Invalid - operation")
	end
end

function Equation.__mul(lhs, rhs)
	if type(rhs) == "number" then
		return Equation.new(EquationVariant.Multiplication, { lhs, Number(rhs) })
	elseif getmetatable(rhs) == Equation then
		return Equation.new(EquationVariant.Multiplication, { lhs, rhs })
	else
		error("Invalid * operation")
	end
end

function Equation.__div(lhs, rhs)
	if type(rhs) == "number" then
		return Equation.new(EquationVariant.Division, { lhs, Number(rhs) })
	elseif getmetatable(rhs) == Equation then
		return Equation.new(EquationVariant.Division, { lhs, rhs })
	else
		error("Invalid * operation")
	end
end

function Equation.__pow(lhs, rhs)
	if type(rhs) == "number" then
		return Equation.new(EquationVariant.Exponentation, { lhs, Number(rhs) })
	elseif getmetatable(rhs) == Equation then
		return Equation.new(EquationVariant.Exponentation, { lhs, rhs })
	else
		error("Invalid ^ operation")
	end
end

function Equation:__unm()
	return Equation.new(EquationVariant.Negation, self)
end

---@param state table<string, number>
function Equation:eval(state)
	local v, tv = self.variant, EquationVariant
	if v == tv.Number then
		return self.data
	elseif v == tv.Symbol then
		return assert(state[self.data], "Undefined variable at runtime: " .. self.data)
	elseif v == tv.Addition then
		return self.data[1]:eval(state) + self.data[2]:eval(state)
	elseif v == tv.Subtraction then
		return self.data[1]:eval(state) - self.data[2]:eval(state)
	elseif v == tv.Multiplication then
		return self.data[1]:eval(state) * self.data[2]:eval(state)
	elseif v == tv.Division then
		return self.data[1]:eval(state) / self.data[2]:eval(state)
	elseif v == tv.Negation then
		return -self.data:eval(state)
	elseif v == tv.Exponentation then
		return self.data[1]:eval(state) ^ self.data[2]:eval(state)
	elseif v == tv.Sin then
		return math.sin(self.data:eval(state))
	elseif v == tv.Cos then
		return math.cos(self.data:eval(state))
	end

	error("Unimplemented: " .. v)
end

function Equation:const()
	return self.variant == EquationVariant.Number
end

---@param val string|Equation
---@param state table<string, number>
---@return Equation
function Equation:d(val, state)
	if getmetatable(val) == Equation then
		assert(val.variant == EquationVariant.Symbol, "Cannot differentiate by equation")
		val = val.data
	end

	local v, tv = self.variant, EquationVariant
	if v == tv.Number then
		return Number(0)
	elseif v == tv.Symbol then
		if val == self.data then
			return Number(1)
		else
			return Number(0) -- Treat as constant, not deriving by symbol. Should really be d(sym)/d(val) but this works for now.
		end
	elseif v == tv.Addition then
		return Equation.new(EquationVariant.Addition, {self.data[1]:d(val), self.data[2]:d(val) })
	elseif v == tv.Subtraction then
		return Equation.new(EquationVariant.Subtraction, { self.data[1]:d(val), self.data[2]:d(val) })
	elseif v == tv.Multiplication then
		local lhs, rhs = self.data[1], self.data[2]
		if lhs:const() and rhs:const() then
			return Number(0)
		elseif lhs:const() then
			error("Unimplemented: lhs:const()")
		else -- Product rule
			return Equation.new(EquationVariant.Addition, {
				Equation.new(EquationVariant.Multiplication, {
					self.data[1]:d(val), self.data[2]
				}),
				Equation.new(EquationVariant.Multiplication, {
					self.data[1], self.data[2]:d(val)
				})
			})
		end
	elseif v == tv.Division then
		error("Unimplemented: Division rule") -- (LoDHi - HiDLo) / Lo ^ 2
	elseif v == tv.Negation then
		self.data = self.data:d(val)
		return self
	elseif v == tv.Exponentation then
		return Equation.new(tv.Exponentation, {self.data[1]:eval(state), self.data[2]:eval(state)})
	elseif v == tv.Sin then -- cos(x) * dx
		return Equation.new(tv.Multiplication, {Equation.new(tv.Cos, self.data), self.data:d(val)})
	elseif v == tv.Cos then -- -sin(x) * dx
		return Equation.new(tv.Multiplication, {Equation.new(tv.Negation, Equation.new(tv.Sin, self.data)), self.data:d(val)})
	end

	error("Unimplemented: " .. v)
end

local trig = {}

function trig.sin(rad)
	if type(rad) == "number" then
		return Equation.new(EquationVariant.Sin, Number(rad))
	elseif getmetatable(rad) == Equation then
		return Equation.new(EquationVariant.Sin, rad)
	else
		error("Invalid sin operation")
	end
end

function trig.cos(rad)
	if type(rad) == "number" then
		return Equation.new(EquationVariant.Cos, Number(rad))
	elseif getmetatable(rad) == Equation then
		return Equation.new(EquationVariant.Cos, rad)
	else
		error("Invalid cos operation")
	end
end

function trig.tan(rad)
	if type(rad) == "number" then
		return Equation.new(EquationVariant.Division, {
			Equation.new(EquationVariant.Sin, Number(rad)),
			Equation.new(EquationVariant.Cos, Number(rad))
		})
	elseif getmetatable(rad) == Equation then
		return Equation.new(EquationVariant.Division, {
			Equation.new(EquationVariant.Sin, rad),
			Equation.new(EquationVariant.Cos, rad)
		})
	else
		error("Invalid tan operation")
	end
end

function trig.csc(rad)
	if type(rad) == "number" then
		return Equation.new(EquationVariant.Division, {
			Number(1),
			Equation.new(EquationVariant.Sin, Number(rad))
		})
	elseif getmetatable(rad) == Equation then
		return Equation.new(EquationVariant.Division, {
			Number(1),
			Equation.new(EquationVariant.Sin, rad)
		})
	else
		error("Invalid csc operation")
	end
end

function trig.sec(rad)
	if type(rad) == "number" then
		return Equation.new(EquationVariant.Division, {
			Number(1),
			Equation.new(EquationVariant.Cos, Number(rad))
		})
	elseif getmetatable(rad) == Equation then
		return Equation.new(EquationVariant.Division, {
			Number(1),
			Equation.new(EquationVariant.Cos, rad)
		})
	else
		error("Invalid sec operation")
	end
end

function trig.cot(rad)
	if type(rad) == "number" then
		return Equation.new(EquationVariant.Division, {
			Equation.new(EquationVariant.Cos, Number(rad)),
			Equation.new(EquationVariant.Sin, Number(rad))
		})
	elseif getmetatable(rad) == Equation then
		return Equation.new(EquationVariant.Division, {
			Equation.new(EquationVariant.Cos, rad),
			Equation.new(EquationVariant.Sin, rad)
		})
	else
		error("Invalid cot operation")
	end
end

return {
	Symbol = Symbol,
	Equation = Equation,
	Number = Number,

	trig = trig
}