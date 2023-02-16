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

	Negation = 10
}

function Equation:__tostring()
	local v, tv = self.variant, EquationVariant
	if v == tv.Integer or v == tv.Decimal then
		return tostring(self.data)
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
	elseif v == tv.Symbol then
		return self.data
	elseif v == tv.Number then
		return tostring(self.data)
	else
		return "Unimplemented"
	end
end

function Equation.__add(lhs, rhs)
	if type(rhs) == "number" then
		return Equation.new(EquationVariant.Addition, { lhs, Equation.new(EquationVariant.Number, rhs) })
	elseif getmetatable(rhs) == Equation then
		return Equation.new(EquationVariant.Addition, { lhs, rhs })
	else
		error("Invalid + operation")
	end
end

function Equation.__sub(lhs, rhs)
	if type(rhs) == "number" then
		return Equation.new(EquationVariant.Subtraction, { lhs, Equation.new(EquationVariant.Number, rhs) })
	elseif getmetatable(rhs) == Equation then
		return Equation.new(EquationVariant.Subtraction, { lhs, rhs })
	else
		error("Invalid - operation")
	end
end

function Equation.__mul(lhs, rhs)
	if type(rhs) == "number" then
		return Equation.new(EquationVariant.Multiplication, { lhs, Equation.new(EquationVariant.Number, rhs) })
	elseif getmetatable(rhs) == Equation then
		return Equation.new(EquationVariant.Multiplication, { lhs, rhs })
	else
		error("Invalid * operation")
	end
end

function Equation.__div(lhs, rhs)
	if type(rhs) == "number" then
		return Equation.new(EquationVariant.Division, { lhs, Equation.new(EquationVariant.Number, rhs) })
	elseif getmetatable(rhs) == Equation then
		return Equation.new(EquationVariant.Division, { lhs, rhs })
	else
		error("Invalid * operation")
	end
end

function Equation.__pow(lhs, rhs)
	if type(rhs) == "number" then
		return Equation.new(EquationVariant.Exponentation, { lhs, Equation.new(EquationVariant.Number, rhs) })
	elseif getmetatable(rhs) == Equation then
		return Equation.new(EquationVariant.Exponentation, { lhs, rhs })
	else
		error("Invalid ^ operation")
	end
end

function Equation:__unm()
	return Equation.new(EquationVariant.Negation, self)
end

function Equation:eval(state)
	local v, tv = self.variant, EquationVariant
	if v == tv.Integer or v == tv.Decimal then
		return self.data
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
	elseif v == tv.Symbol then
		return assert(state[self.data], "Undefined variable at runtime")
	elseif v == tv.Number then
		return self.data
	end
end

function Equation:const()
	return self.variant == EquationVariant.Number
end

---@return Equation
function Equation:d(val, state)
	local v, tv = self.variant, EquationVariant
	if v == tv.Number then
		return Equation.new(tv.Number, 0)
	elseif v == tv.Addition then
		return Equation.new(EquationVariant.Addition, {self.data[1]:d(val), self.data[2]:d(val) })
	elseif v == tv.Subtraction then
		return Equation.new(EquationVariant.Subtraction, { self.data[1]:d(val), self.data[2]:d(val) })
	elseif v == tv.Multiplication then
		local lhs, rhs = self.data[1], self.data[2]
		if lhs:const() and rhs:const() then
			return Equation.new(tv.Number, 0)
		elseif lhs:const() then
			error("Unimplemented")
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
		error("Unimplemented: Division rule")
	elseif v == tv.Negation then
		self.data = self.data:d(val)
		return self
	elseif v == tv.Exponentation then
		return Equation.new(tv.Exponentation, {self.data[1]:eval(state), self.data[2]:eval(state)})
	elseif v == tv.Symbol then
		if val == self.data then
			return Equation.new(tv.Number, 1)
		else
			return self.data
		end
	end

	error("Unimplemented")
end

---@param ident string
function Symbol(ident)
	return setmetatable({ variant = EquationVariant.Symbol, data = ident }, Equation)
end

return {
	Symbol = Symbol
}