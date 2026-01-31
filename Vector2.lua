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