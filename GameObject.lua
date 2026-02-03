require("utils")
local Vector2 = require("Vector2")

local GameObject = {}
GameObject.new = function()
    local self = {}
    self.imageRatio = 0.55
    self.imageRatioRef = 0.35

    -- Position, velocity and acceleration as vectors
    self.position = Vector2.new(SCREEN_WIDTH / 2, SCREEN_HIGH / 2)
    self.velocity = Vector2.new(0, 0)
    self.velocityMax = Vector2.new(0, 0)
    
    self.angle = (3 / 2 * math.pi) --1.5 * math.pi
    self.accelerateFWorWW = "neutral"
    self.rotateRightorLeft = "neutral"


    self.imageRadius = 0

    self.MAX_EXTENDED_IMAGE_RADIUS_FACTOR = 3
    local STD_EXTENDED_IMAGE_RADIUS_FACTOR = 1
    local extendedImageRadiusFactor = 1
    local previousAngle = (3 / 2 * math.pi) --1.5 * math.pi

    self.SIDE_GUN_ANGLE_OFFSET = 0.5
    self.GUN_POSITION_X_OFFSET = 9
    self.GUN_POSITION_Y_OFFSET = 0
    self.SIDE_GUN_POSITION_X_OFFSET = 7
    self.SIDE_GUN_POSITION_Y_OFFSET = 11

    self.RIGHT = 102
    self.LEFT = 103
    -- type_missile shared between vaisseau and bonus
    self.MSL_PKG_STD = 1
    self.MSL_PKG_LATERAL = 2
    self.MSL_PKG_MUCH_LATERAL = 3
    self.MSL_PKG_BIGGER = 4
    self.MSL_PKG_MUCH_BIGGER = 5
    self.MSL_PKG_QUICKER = 6
    self.MSL_PKG_MUCH_QUICKER = 7
    self.MSL_LASER_SIGHT = 8
    self.SHIELD = 9
    self.MSL_SINUS = 10
    self.MSL_PKG_LAST_END = 11

    -- Create a lookup table
    self.lookupWeaponsLevel = {
    [self.MSL_PKG_STD] = 1,
    [self.MSL_PKG_LATERAL] = 2,
    [self.MSL_PKG_MUCH_LATERAL] = 3,
    [self.MSL_PKG_BIGGER] = 2,
    [self.MSL_PKG_MUCH_BIGGER] = 3,
    [self.MSL_PKG_QUICKER] = 2,
    [self.MSL_PKG_MUCH_QUICKER] = 3,
    [self.MSL_LASER_SIGHT] = 2,
    [self.SHIELD] = 2,
    [self.MSL_SINUS] = 2
    -- MSL_PKG_LAST_END is not mapped
    }

    self.maneuverability = 4.8

    function self.rotate(clockwise, dt)
        local sign

        if clockwise == true then
            sign = 1
            self.rotateRightorLeft = "right"
        elseif clockwise == false then
            sign = -1
            self.rotateRightorLeft = "left"
        end
        self.angle = (self.angle + (self.maneuverability * sign *dt) ) % (2 * math.pi)
        if (previousAngle == self.angle) then
            self.rotateRightorLeft = "neutral"
        end
        previousAngle = self.angle
    end

    function self.move(dt)
        -- update position using velocity vector
        self.position = self.position:add(self.velocity:scale(dt))

        -- no collision, this is movement (bounce on screen edges)
        if ((self.position.x > SCREEN_WIDTH and self.velocity.x > 0) or (self.velocity.x < 0 and self.position.x < 0)) then
            self.velocity.x = -self.velocity.x
        elseif ((self.position.y > SCREEN_HIGH and self.velocity.y > 0) or (self.velocity.y < 0 and self.position.y < 0)) then
            self.velocity.y = -self.velocity.y
        end
    end

    function self.stop(dt)
        self.velocity = Vector2.new(0, 0)
    end

    function self.accelerateBack(dt, speedMax, accelerationMax)
        local goBack = true
        self.accelerate(dt, speedMax, accelerationMax, goBack)
    end

    function self.collisionWith(Object, startLevel)
        startLevel = startLevel or false
        if (startLevel == true) then
            extendedImageRadiusFactor = self.MAX_EXTENDED_IMAGE_RADIUS_FACTOR
        else
            extendedImageRadiusFactor = STD_EXTENDED_IMAGE_RADIUS_FACTOR
        end

        -- Compute the distance between this object and `Object` using vector ops:
        -- `Object.position:sub(self.position)` builds the vector from `self.position`
        -- to `Object.position`. Calling `:length()` returns its magnitude (distance).
        local dist = Object.position:sub(self.position):length()
        -- Compare the distance to the sum of radii (with potential extension).
        return dist < (self.imageRadius * extendedImageRadiusFactor + Object.imageRadius)
    end

    function self.distanceWith(Object)
        -- Returns the scalar distance between this object and `Object`.
        return Object.position:sub(self.position):length()
    end

    function self.accelerate(dt, velocityMax, accelerationMax, goBack)
        goBack = goBack or false

        if (goBack) then
            self.accelerateFWorWW = "backward"
            self.velocity.x = self.velocity.x - (math.cos(self.angle) * accelerationMax)
            self.velocity.y = self.velocity.y - (math.sin(self.angle) * accelerationMax)
        else
            self.accelerateFWorWW = "forward"
            self.velocity.x = self.velocity.x + (math.cos(self.angle) * accelerationMax)
            self.velocity.y = self.velocity.y + (math.sin(self.angle) * accelerationMax)
        end

        local absMaxSpeedX = 0
        local absMaxSpeedY = 0

        if ((self.velocity.x ~= 0) and (self.velocity.y ~= 0)) then
            local mag = self.velocity:length()
            if mag ~= 0 then
                local norm = self.velocity:normalize()
                self.velocityMax.x = norm.x * velocityMax
                self.velocityMax.y = norm.y * velocityMax
                absMaxSpeedX = math.abs(self.velocityMax.x)
                absMaxSpeedY = math.abs(self.velocityMax.y)
            end
        end

        if ((self.velocity.x ~= 0) and (self.velocity.y ~= 0)) then
            if (math.abs(self.velocity.x) >= absMaxSpeedX) then
                self.velocity.x = self.velocityMax.x
            end
            if (math.abs(self.velocity.y) >= absMaxSpeedY) then
                self.velocity.y = self.velocityMax.y
            end
        end
    end

    function self.print_infos(Object, printX, printY)
        love.graphics.print(table.concat({
            Object .. " -->",
            'Angle Radian : ' .. string.format("%5.1f", self.angle),
            'Angle Degre : ' .. string.format("%5.1f", ((360 / (2 * math.pi)) * self.angle)),
            'X: ' .. string.format("%5.1f", self.position.x),
            'Y: ' .. string.format("%5.1f", self.position.y),
            'SpeedX: ' .. string.format("%5.1f", self.velocity.x),
            'SpeedY: ' .. string.format("%5.1f", self.velocity.y),
            'VelocityMaxX: ' .. string.format("%5.1f", self.velocityMax.x),
            'VelocityMaxY: ' .. string.format("%5.1f", self.velocityMax.y),
        }, '\n'), printX, printY)
    end

    function self.graphic_infos()
        local factor = 20 / 60
        love.graphics.setColor(255, 0, 0)
        love.graphics.line(self.position.x, self.position.y, self.position.x + (self.velocityMax.x * factor),
            self.position.y + (self.velocityMax.y * factor))
        love.graphics.setColor(0, 255, 0)
        love.graphics.line(self.position.x, self.position.y, self.position.x + (self.velocityMax.x * factor),
            self.position.y + (self.velocityMax.y * factor))
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.circle("line", self.position.x, self.position.y, self.imageRadius)
    end
    return self
end

return GameObject
