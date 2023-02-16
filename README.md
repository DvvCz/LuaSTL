# LuaSTL

Standard library for lua, mostly for using lua as a command line tool.

## Usage

Clone this repository into the same folder where you installed your lua(jit) binary.
Then `require "std"`

### Http

This has a small helper to easily make synchronous http requests.
Currently only supports windows (using powershell).

```lua
local std = require "std"
print( std.net.http.get("https://google.com") )
```

### Math

This has a small symbolic math library (just because)

```lua
local std = require "std" -- Symbol is auto-exported

local x, y = Symbol "x", Symbol "y"

local equation = x * 2 + y
print( equation:eval({ x = 5, y = 2 }) ) -- 12

-- Symbolic differentation
print( equation:d(x) ) -- 1 * 2 + x * 0 + 0 (simplifies to 2)
```

And vector math

```lua
local std = require "std" -- Vector (alongside aliases in case of casing/typo errors are exposed with the stl)
print( Vector(1, 2, 3) + Vector(-1, -2, -3) ) -- Vector(0.0, 0.0, 0.0)
```