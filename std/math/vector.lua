-- Tiny vector library as a math helper

---@class Vector
---@field x number
---@field y number
---@field z number
local Vector = {}
Vector.__index = Vector

---@param x number
---@param y number
---@param z number
function Vector.new(x, y, z)
	return setmetatable({x = x or 0, y = y or 0, z = z or 0}, Vector)
end

function Vector:__mul(rhs)
	if type(rhs) == "number" then
		return Vector.new(self.x * rhs, self.y * rhs, self.z * rhs)
	else
		return Vector.new(self.x * rhs.x, self.y * rhs.y, self.z * rhs.z)
	end
end

function Vector:__div(rhs)
	if type(rhs) == "number" then
		return Vector.new(self.x / rhs, self.y / rhs, self.z / rhs)
	else
		return Vector.new(self.x / rhs.x, self.y / rhs.y, self.z / rhs.z)
	end
end

function Vector:__add(rhs)
	if type(rhs) == "number" then
		return Vector.new(self.x + rhs, self.y + rhs, self.z + rhs)
	else
		return Vector.new(self.x + rhs.x, self.y + rhs.y, self.z + rhs.z)
	end
end

function Vector:__sub(rhs)
	if type(rhs) == "number" then
		return Vector.new(self.x - rhs, self.y - rhs, self.z - rhs)
	else
		return Vector.new(self.x - rhs.x, self.y - rhs.y, self.z - rhs.z)
	end
end

function Vector:__tostring()
	return string.format("Vector(%.02f, %.02f, %.02f)", self.x, self.y, self.z)
end

function Vector:len()
	return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
end

Vector.Len = Vector.len
Vector.length = Vector.len
Vector.Length = Vector.len

---@param rhs Vector?
function Vector:dist(rhs)
	if rhs then
		assert(type(rhs) == "table", "expected vector for vector:dist(vector?)")
		return (self - rhs):len()
	else -- distance to origin
		return self:len()
	end
end

Vector.Dist = Vector.dist
Vector.distance = Vector.dist
Vector.Distance = Vector.dist

---@param rhs Vector
function Vector:dot(rhs)
	if rhs then
		assert(type(rhs) == "table", "expected vector for vector:dot(rhs)")
		return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z
	end
end

Vector.Dot = Vector.dot

_G.vec = Vector.new
_G.vector = Vector.new
_G.vec3 = Vector.new
_G.Vec = Vector.new
_G.Vector = Vector.new
_G.Vector3 = Vector.new

return Vector.new