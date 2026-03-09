-- a mettre dans outils tools.lua !!!
function randomBool()
    local bool = false
    local num = math.random(0, 1)
    if num == 0 then
        bool = false
    elseif num == 1 then
        bool = true
    end
    return bool
end

function toggleBool(boolToToggle)
    if boolToToggle == true then
        boolToToggle = false
    else
        boolToToggle = true
    end
    return boolToToggle
end

function randomSign()
    local num = math.random(0, 1)
    if num == 0 then num = -1 end
    return num
end

function sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function isEven(number)
    if number % 2 == 0 then
        return true
    else
        return false
    end
end

function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- Gamepad helper utilities
function getFirstGamepad()
    local js = love.joystick.getJoysticks()
    if js == nil then return nil end
    for i = 1, #js do
        local j = js[i]
        local ok, isGamepad = pcall(function() return j:isGamepad() end)
        if ok and isGamepad then return j end
    end
    return js[1]
end

function gamepadIsDown(name)
    local gp = getFirstGamepad()
    if not gp then return false end
    local ok, val = pcall(function() return gp:isGamepadDown(name) end)
    if ok then return val end
    return false
end

-- Try a list of axis names and return the first non-zero value found
function gamepadAxisValue(...)
    local gp = getFirstGamepad()
    if not gp then return 0 end
    local names = {...}
    for i = 1, #names do
        local name = names[i]
        local ok, val = pcall(function() return gp:getGamepadAxis(name) end)
        if ok and val and val ~= 0 then return val end
    end
    return 0
end
