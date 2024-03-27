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
