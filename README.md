# LuaSTL

Standard library for lua, mostly for using lua as a command line tool.  
Inspired by the [Rust](https://www.rust-lang.org/) standard library, alongside projects like [Sympy](https://github.com/sympy/sympy)

## Usage

Clone this repository into the same folder where you installed your lua(jit) binary.
Then `require "std"`

### Http

This has a small helper to easily make synchronous http requests (uses PowerShell/cURL internally)

```lua
local std = require "std"
print( std.net.http.get("https://google.com") )
```

### Math

This has a small symbolic math library (just because)

```lua
local std = require "std"
local sin = std.math.symbolic.trig.sin

local x, y = Symbol "x", Symbol "y"
local equation = sin(x * 5) + x * 2 + y

print( equation:eval { x = 5, y = 2 } ) -- 12

-- Symbolic differentation
print( equation:d(x, {}) ) -- cos(x * 5) * 1 * 5 + x * 0 + 1 * 2 + x * 0 + 0 (simplifies to 5cos(5x) + 2)
```

And vector math

```lua
local std = require "std" -- Vector (alongside aliases in case of casing/typo errors are exposed with the stl)
print( Vector(1, 2, 3) + Vector(-1, -2, -3) ) -- Vector(0.0, 0.0, 0.0)
```

### Tests

```lua
local T = std.test.Test.new("unit test")

function T.__start(state)
	state.x = 10
end

function T.__stop(state)
	assert(state.x == 5)
end

function T.test_foo(state)
	print("Testing the foo")
	state.x = state.x / 2
end

function T.test_bar(state)
	error("the bar")
end

T:run()
```