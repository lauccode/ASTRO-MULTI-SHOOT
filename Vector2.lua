-- Simple 2D vector utility.
-- Methods provided:
--  - `Vector2.new(x, y)`        : create a new vector
--  - `v:add(u)`                 : return v + u (new Vector2)
--  - `v:sub(u)`                 : return v - u (new Vector2)
--  - `v:scale(s)`               : return v * s (new Vector2)
--  - `v:dot(u)`                 : dot product
--  - `v:length()`               : length (magnitude) of the vector
--  - `v:normalize()`            : unit vector in same direction (zero -> (0,0))
--
-- Usage examples:
--   local a = Vector2.new(1,2)
--   local b = Vector2.new(3,4)
--   local d = b:sub(a):length()  -- distance between a and b
--   local dir = b:sub(a):normalize() -- unit direction from a to b

local Vector2 = {}
Vector2.__index = Vector2

function Vector2.new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vector2)
end

function Vector2:add(v)
    return Vector2.new(self.x + v.x, self.y + v.y)
end

function Vector2:sub(v)
    return Vector2.new(self.x - v.x, self.y - v.y)
end

function Vector2:scale(s)
    return Vector2.new(self.x * s, self.y * s)
end

function Vector2:dot(v)
    return self.x * v.x + self.y * v.y
end

function Vector2:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector2:normalize()
    local len = self:length()
    if len == 0 then return Vector2.new(0, 0) end
    return Vector2.new(self.x / len, self.y / len)
end

return Vector2