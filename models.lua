require("utils")

GameObject = {}
GameObject.new = function()
    local self = {}
    self.imageRatio = 0.55
    self.imageRatioRef = 0.35
    self.X_pos = SCREEN_WIDTH / 2
    self.Y_pos = SCREEN_HIGH / 2
    self.speedX = 0
    self.speedY = 0
    self.angle = (3 / 2 * math.pi) --1.5 * math.pi
    self.accelerateFWorWW = "neutral"
    self.rotateRightorLeft = "neutral"

    self.accelerationX = 0
    self.accelerationY = 0

    self.imageRadius = 0

    self.MAX_EXTENDED_IMAGE_RADIUS_FACTOR = 3
    local STD_EXTENDED_IMAGE_RADIUS_FACTOR = 1
    local extendedImageRadiusFactor = 1
    local startLevelActivated = false
    local previousAngle = (3 / 2 * math.pi) --1.5 * math.pi

    self.SIDE_GUN_ANGLE_OFFSET = 0.7
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
        self.X_pos = self.X_pos + self.speedX*dt
        self.Y_pos = self.Y_pos + self.speedY*dt

        -- no collision, this is movement
        if ((self.X_pos > SCREEN_WIDTH and self.speedX > 0) or (self.speedX < 0 and self.X_pos < 0)) then
            self.speedX = -self.speedX
        elseif ((self.Y_pos > SCREEN_HIGH and self.speedY > 0) or (self.speedY < 0 and self.Y_pos < 0)) then
            self.speedY = -self.speedY
        end
    end

    function self.stop(dt)
        self.speedX = 0
        self.speedY = 0
    end

    function self.accelerateBack(dt, acceleration, accelerationMax)
        local goBack = true
        self.accelerate(dt, acceleration, accelerationMax, goBack)
    end

    function self.collisionWith(Object, startLevel)
        startLevel = startLevel or false
        if (startLevel == true) then
            extendedImageRadiusFactor = self.MAX_EXTENDED_IMAGE_RADIUS_FACTOR
        else
            extendedImageRadiusFactor = STD_EXTENDED_IMAGE_RADIUS_FACTOR
        end

        local dx = Object.X_pos - self.X_pos
        local dy = Object.Y_pos - self.Y_pos
        local dist = math.sqrt(dx * dx + dy * dy)
        return dist < (self.imageRadius * extendedImageRadiusFactor + Object.imageRadius)
    end

    function self.distanceWith(Object)
        local dx = Object.X_pos - self.X_pos
        local dy = Object.Y_pos - self.Y_pos
        local dist = math.sqrt(dx * dx + dy * dy)
        return dist
    end

    function self.accelerate(dt, acceleration, accelerationMax, goBack)
        goBack = goBack or false

        if (goBack) then
            self.accelerateFWorWW = "backward"
            self.speedX = self.speedX - (math.cos(self.angle) * accelerationMax)
            self.speedY = self.speedY - (math.sin(self.angle) * accelerationMax)
        else
            self.accelerateFWorWW = "forward"
            self.speedX = self.speedX + (math.cos(self.angle) * accelerationMax)
            self.speedY = self.speedY + (math.sin(self.angle) * accelerationMax)
        end

        if ((self.speedX ~= 0) and (self.speedY ~= 0)) then
            -- fully needed to avoid "diagonal effect"
            local cosinus = self.speedX / math.sqrt(math.pow(self.speedX, 2) + math.pow(self.speedY, 2))
            local sinus = self.speedY / math.sqrt(math.pow(self.speedX, 2) + math.pow(self.speedY, 2))

            self.accelerationX = cosinus * acceleration
            self.accelerationY = sinus * acceleration
            self.absMaxSpeedX = math.abs(self.accelerationX)
            self.absMaxSpeedY = math.abs(self.accelerationY)
        end

        if ((self.speedX ~= 0) and (self.speedY ~= 0)) then
            -- fully needed to avoid "diagonal effect"
            if (math.abs(self.speedX) >= self.absMaxSpeedX) then
                -- self.speedX = clamp(-self.absMaxSpeedX, self.speedX, self.absMaxSpeedX)
                self.speedX = self.accelerationX
            end
            if (math.abs(self.speedY) >= self.absMaxSpeedY) then
                -- self.speedY = clamp(-self.absMaxSpeedY, self.speedY, self.absMaxSpeedY)
                self.speedY = self.accelerationY
            end
        end
    end

    function self.print_infos(Object, printX, printY)
        love.graphics.print(table.concat({
            Object .. " -->",
            'Angle Radian : ' .. string.format("%5.1f", self.angle),
            'Angle Degre : ' .. string.format("%5.1f", ((360 / (2 * math.pi)) * self.angle)),
            'X: ' .. string.format("%5.1f", self.X_pos),
            'Y: ' .. string.format("%5.1f", self.Y_pos),
            'SpeedX: ' .. string.format("%5.1f", self.speedX),
            'SpeedY: ' .. string.format("%5.1f", self.speedY),
            'AccelerationX: ' .. string.format("%5.1f", self.accelerationX),
            'AccelerationY: ' .. string.format("%5.1f", self.accelerationY),
        }, '\n'), printX, printY)
    end

    function self.graphic_infos()
        local factor = 20 / 60
        love.graphics.setColor(255, 0, 0)
        love.graphics.line(self.X_pos, self.Y_pos, self.X_pos + (self.accelerationX * factor),
            self.Y_pos + (self.accelerationY * factor))
        love.graphics.setColor(0, 255, 0)
        love.graphics.line(self.X_pos, self.Y_pos, self.X_pos + (self.speedX * factor),
            self.Y_pos + (self.speedY * factor))
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.circle("line", self.X_pos, self.Y_pos, self.imageRadius)
    end

    return self
end


-- ██    ██  █████  ██ ███████ ███████ ███████  █████  ██    ██
-- ██    ██ ██   ██ ██ ██      ██      ██      ██   ██ ██    ██
-- ██    ██ ███████ ██ ███████ ███████ █████   ███████ ██    ██
--  ██  ██  ██   ██ ██      ██      ██ ██      ██   ██ ██    ██
--   ████   ██   ██ ██ ███████ ███████ ███████ ██   ██  ██████
Vaisseau = {}
Vaisseau.new = function(level)
    local self = GameObject.new()
    self.nameInstance = "VAISSEAU"
    local PropulsorPng = love.graphics.newImage("sprites/propulsor.png")
    local VaisseauPngImpact = love.graphics.newImage("sprites/vaisseau_retro_impact.png")
    self.vaisseauImpact = false
    local IMPACT_DURATION = 10     -- 1/6 second
    local vaisseauImpactDuration = IMPACT_DURATION
    local PROPULSOR_POWER_MAX = 60 -- 1/6 second
    local propulsorIncreasePowerTab = { 0, 0, 0, 0 }
    self.protection = 10           -- 10

    self.missilePackLateral = self.MSL_PKG_STD
    self.missilePackBigger = self.MSL_PKG_STD
    self.missilePackQuicker = self.MSL_PKG_STD
    self.missileLaserSight = self.MSL_PKG_STD
    self.missileSinus = self.MSL_PKG_STD
    self.shield = self.MSL_PKG_STD
    local nameMissilePack = { "DISABLED", "LATERAL", "TRIPLE", "BIGGER", "MUCH BIGGER", "MACHINE GUN",
        "SUPER MACHINE GUN", "LASER_SIGHT", "SHIELD", "MSL_SINUS" }

	self.SHOOT_TIMER_LIMIT = 30             --
	self.SHOOT_MACHINE_GUN_TIMER_LIMIT = 20 -- shot speed
	self.SHOOT_MUCH_MACHINE_GUN_TIMER_LIMIT = 10

    local widthImage = 0
    local heightImage = 0
    -- local colorValueIncrease = 0
    local PROPULSOR_LOW_LEFT = 1
    local PROPULSOR_LOW_RIGHT = 2
    local PROPULSOR_HIGHT_LEFT = 3
    local PROPULSOR_HIGHT_RIGHT = 4

    local X_PROPULSOR_LOW_LEFT = -7
    local X_PROPULSOR_LOW_RIGHT = -7
    local X_PROPULSOR_HIGHT_LEFT = 14
    local X_PROPULSOR_HIGHT_RIGHT = 14
    local Y_PROPULSOR_LOW_LEFT = -11
    local Y_PROPULSOR_LOW_RIGHT = 11
    local Y_PROPULSOR_HIGHT_LEFT = -11
    local Y_PROPULSOR_HIGHT_RIGHT = 11

    -- Particles
    local smokeImg = love.graphics.newImage('sprites/smoke.png')
    local particle = {}
    particle.posX = {}
    particle.posY = {}
    local particle_number = 1

    local VaisseauPng = love.graphics.newImage("sprites/vaisseau_retro_rouge.png")
    local widthImage = VaisseauPng:getWidth()
    local heightImage = VaisseauPng:getHeight()
    local widthImageProp = PropulsorPng:getWidth()
    local heightImageProp = PropulsorPng:getHeight()
    self.imageRadius = (widthImage / 2) * self.imageRatio

    self.TIME_SHIELD_START_MAX = 60 * 5
    self.timeShieldStart = nil --seconds

    self.imageRatio = 0.55
    self.imageRatioRef = 0.35

    self.toggleShootLeftRight = false

	self.acceleration = 180
	self.accelerationMax = 6
	self.missileAcceleration = 5*60
	self.missileAccelerationMax = 60

	self.colorValueIncrease = 0

    local propulsorX_LOW_LEFT = 0
    local propulsorY_LOW_LEFT = 0
    local propulsorIncreasePower_LOW_LEFT = 0

    local propulsorX_LOW_RIGHT = 0
    local propulsorY_LOW_RIGHT = 0
    local propulsorIncreasePower_LOW_RIGHT = 0

    local propulsorX_HIGHT_LEFT = 0
    local propulsorY_HIGHT_LEFT = 0
    local propulsorIncreasePower_HIGHT_LEFT = 0

    local propulsorX_HIGHT_RIGHT = 0
    local propulsorY_HIGHT_RIGHT = 0
    local propulsorIncreasePower_HIGHT_RIGHT = 0
    local angle_LOW = 0
    local angle_HIGHT = 0

    local function shieldCircle(extension)
        for extensionToDo = 1, extension do
            love.graphics.circle("line", self.X_pos, self.Y_pos,
                self.imageRadius * self.MAX_EXTENDED_IMAGE_RADIUS_FACTOR + (extensionToDo - 1))
        end
    end

    function self.updatePrintWarningStartLevel(dt)
        self.timeShieldStart = self.timeShieldStart + (60*dt) -- count time from start of level
        self.colorValueIncrease = self.colorValueIncrease + (5*60*dt)
    end
    
    local function printWarningStartLevel()
        if (self.colorValueIncrease > 255) then self.colorValueIncrease = 0 end
        local font = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 18)
        love.graphics.setFont(font)
        love.graphics.setColor(255, 255, 0)         --yellow
        love.graphics.print("WARNING - SHIELD OFF IN : " ..
            tostring(string.format("%d", (self.TIME_SHIELD_START_MAX / 60 - self.timeShieldStart / 60))),
            self.X_pos - widthImage, self.Y_pos - self.imageRadius * (self.MAX_EXTENDED_IMAGE_RADIUS_FACTOR + 1))
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setColor(love.math.colorFromBytes(self.colorValueIncrease, 0, 0))
        shieldCircle(3)
        love.graphics.setColor(255, 255, 255, 255)
    end

    local function propulsorIncreasePow(dt, PropulsorWithV, active, propulsorIncreasePowerTab)
        if (active) then
            if (propulsorIncreasePowerTab[PropulsorWithV] < PROPULSOR_POWER_MAX) then
                propulsorIncreasePowerTab[PropulsorWithV] = propulsorIncreasePowerTab[PropulsorWithV] + 1
            end
        else
            propulsorIncreasePowerTab[PropulsorWithV] = 0
        end
        return propulsorIncreasePowerTab[PropulsorWithV]
    end

   local function  updateParticles(active, particles, propulsorX, propulsorY, propulsorIncreasePower, angle)
        if (active == true) then
            -- love.graphics.draw(PropulsorPng, propulsorX, propulsorY, angle,
            --     self.imageRatio * ((love.math.random() * 5 + 5) / 10),
            --     (self.imageRatio * 2) * (propulsorIncreasePower / PROPULSOR_POWER_MAX), widthImageProp / 2, 0)

            particle.posX[particle_number] = propulsorX
            particle.posY[particle_number] = propulsorY
            particles[particle_number] = love.graphics.newParticleSystem(smokeImg, propulsorIncreasePower)
            particles[particle_number]:start()
            particles[particle_number]:setEmissionRate(2 * propulsorIncreasePower) -- 150
            particles[particle_number]:setSpeed(10, 50)                         -- min,max  500
            particles[particle_number]:setDirection(angle + 1 / 2 * (math.pi))  -- radians
            particles[particle_number]:setParticleLifetime(1, 2)                -- Particles live at least 1s and at most 2s.
            particles[particle_number]:setSizeVariation(1)
            particles[particle_number]:setLinearAcceleration(-30, -30, 30, 30)  -- Random movement in all directions.
            particles[particle_number]:setColors(1, 1, 1, 1, 1, 1, 1, 0)        -- Fade to transparency.
        else
            particle.posX[particle_number] = propulsorX
            particle.posY[particle_number] = propulsorY
            particles[particle_number] = love.graphics.newParticleSystem(smokeImg, 1)
            particles[particle_number]:stop()
        end

        for particles_it = 1, #particles do
            local powerParticle = particles[particles_it]:getEmissionRate()
            particles[particles_it]:setEmissionRate(powerParticle / 1.05)
            -- love.graphics.draw(particles[particles_it], particle.posX[particles_it], particle.posY[particles_it])
        end

        particle_number = particle_number + 1
        if (particle_number > 120 * 4) then particle_number = 1 end

        return particles
   end

    local function updatePropulsorDrawPositionXY(dt, PropulsorWithV, active, particles)
        active = active or false

        angle_LOW =  self.angle + (0.5 * math.pi)
        angle_HIGHT =  self.angle + (3 / 2 * math.pi)
        if (PropulsorWithV == PROPULSOR_LOW_LEFT) then
            X_offsetPropulsorWithV = X_PROPULSOR_LOW_LEFT * (self.imageRatio / self.imageRatioRef)
            Y_offsetPropulsorWithV = Y_PROPULSOR_LOW_LEFT * (self.imageRatio / self.imageRatioRef)
            propulsorIncreasePower_LOW_LEFT = propulsorIncreasePow(dt, PropulsorWithV, active, propulsorIncreasePowerTab)
            propulsorX_LOW_LEFT = self.X_pos + (math.cos(self.angle) * X_offsetPropulsorWithV) - (math.sin(self.angle) * Y_offsetPropulsorWithV)
            propulsorY_LOW_LEFT = self.Y_pos + (math.sin(self.angle) * X_offsetPropulsorWithV) + (math.cos(self.angle) * Y_offsetPropulsorWithV)
            particles = updateParticles(active, particles, propulsorX_LOW_LEFT,propulsorY_LOW_LEFT, propulsorIncreasePower_LOW_LEFT, angle_LOW)
        elseif (PropulsorWithV == PROPULSOR_LOW_RIGHT) then
            X_offsetPropulsorWithV = X_PROPULSOR_LOW_RIGHT * (self.imageRatio / self.imageRatioRef)
            Y_offsetPropulsorWithV = Y_PROPULSOR_LOW_RIGHT * (self.imageRatio / self.imageRatioRef)
            propulsorIncreasePower_LOW_RIGHT = propulsorIncreasePow(dt, PropulsorWithV, active, propulsorIncreasePowerTab)
            propulsorX_LOW_RIGHT = self.X_pos + (math.cos(self.angle) * X_offsetPropulsorWithV) - (math.sin(self.angle) * Y_offsetPropulsorWithV)
            propulsorY_LOW_RIGHT = self.Y_pos + (math.sin(self.angle) * X_offsetPropulsorWithV) + (math.cos(self.angle) * Y_offsetPropulsorWithV)
            particles = updateParticles(active, particles, propulsorX_LOW_RIGHT,propulsorY_LOW_RIGHT, propulsorIncreasePower_LOW_RIGHT, angle_LOW)
        elseif (PropulsorWithV == PROPULSOR_HIGHT_LEFT) then
            X_offsetPropulsorWithV = X_PROPULSOR_HIGHT_LEFT * (self.imageRatio / self.imageRatioRef)
            Y_offsetPropulsorWithV = Y_PROPULSOR_HIGHT_LEFT * (self.imageRatio / self.imageRatioRef)
            propulsorIncreasePower_HIGHT_LEFT = propulsorIncreasePow(dt, PropulsorWithV, active, propulsorIncreasePowerTab)
            propulsorX_HIGHT_LEFT = self.X_pos + (math.cos(self.angle) * X_offsetPropulsorWithV) - (math.sin(self.angle) * Y_offsetPropulsorWithV)
            propulsorY_HIGHT_LEFT = self.Y_pos + (math.sin(self.angle) * X_offsetPropulsorWithV) + (math.cos(self.angle) * Y_offsetPropulsorWithV)
            particles = updateParticles(active, particles, propulsorX_HIGHT_LEFT,propulsorY_HIGHT_LEFT, propulsorIncreasePower_HIGHT_LEFT, angle_HIGHT)
        elseif (PropulsorWithV == PROPULSOR_HIGHT_RIGHT) then
            X_offsetPropulsorWithV = X_PROPULSOR_HIGHT_RIGHT * (self.imageRatio / self.imageRatioRef)
            Y_offsetPropulsorWithV = Y_PROPULSOR_HIGHT_RIGHT * (self.imageRatio / self.imageRatioRef)
            propulsorIncreasePower_HIGHT_RIGHT = propulsorIncreasePow(dt, PropulsorWithV, active, propulsorIncreasePowerTab)
            propulsorX_HIGHT_RIGHT = self.X_pos + (math.cos(self.angle) * X_offsetPropulsorWithV) - (math.sin(self.angle) * Y_offsetPropulsorWithV)
            propulsorY_HIGHT_RIGHT = self.Y_pos + (math.sin(self.angle) * X_offsetPropulsorWithV) + (math.cos(self.angle) * Y_offsetPropulsorWithV)
            particles = updateParticles(active, particles, propulsorX_HIGHT_RIGHT,propulsorY_HIGHT_RIGHT, propulsorIncreasePower_HIGHT_RIGHT, angle_HIGHT)
        end
        return particles
    end

    local function drawPropulsorPositionXY(particles)
        -- if (active == true) then
            love.graphics.draw(PropulsorPng, propulsorX_LOW_LEFT, propulsorY_LOW_LEFT, angle_LOW,
                self.imageRatio * ((love.math.random() * 5 + 5) / 10),
                (self.imageRatio * 2) * (propulsorIncreasePower_LOW_LEFT / PROPULSOR_POWER_MAX), widthImageProp / 2, 0)
            love.graphics.draw(PropulsorPng, propulsorX_LOW_RIGHT, propulsorY_LOW_RIGHT, angle_LOW,
                self.imageRatio * ((love.math.random() * 5 + 5) / 10),
                (self.imageRatio * 2) * (propulsorIncreasePower_LOW_RIGHT / PROPULSOR_POWER_MAX), widthImageProp / 2, 0)
            love.graphics.draw(PropulsorPng, propulsorX_HIGHT_LEFT, propulsorY_HIGHT_LEFT, angle_HIGHT,
                self.imageRatio * ((love.math.random() * 5 + 5) / 10),
                (self.imageRatio * 2) * (propulsorIncreasePower_HIGHT_LEFT / PROPULSOR_POWER_MAX), widthImageProp / 2, 0)
            love.graphics.draw(PropulsorPng, propulsorX_HIGHT_RIGHT, propulsorY_HIGHT_RIGHT, angle_HIGHT,
                self.imageRatio * ((love.math.random() * 5 + 5) / 10),
                (self.imageRatio * 2) * (propulsorIncreasePower_HIGHT_RIGHT / PROPULSOR_POWER_MAX), widthImageProp / 2, 0)
        -- end

        for particles_it = 1, #particles do
            local powerParticle = particles[particles_it]:getEmissionRate()
            particles[particles_it]:setEmissionRate(powerParticle / 1.05)
            love.graphics.draw(particles[particles_it], particle.posX[particles_it], particle.posY[particles_it])
        end
    end

	function self.updatePropulsor(dt, particles)
        -- propulsor
        if (self.accelerateFWorWW == "forward") then
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_LEFT, true, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_RIGHT, true, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_LEFT, false, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_RIGHT, false, particles)
        elseif (self.accelerateFWorWW == "backward") then
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_LEFT, true, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_RIGHT, true, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_LEFT, false, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_RIGHT, false, particles)
        elseif (self.accelerateFWorWW == "neutral" and self.rotateRightorLeft == "neutral") then
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_LEFT, false, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_RIGHT, false, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_LEFT, false, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_RIGHT, false, particles)
        end

        if (self.rotateRightorLeft == "left") then
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_RIGHT, true, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_LEFT, true, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_LEFT, false, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_RIGHT, false, particles)
        elseif (self.rotateRightorLeft == "right") then
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_LEFT, true, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_RIGHT, true, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_RIGHT, false, particles)
            particles = updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_LEFT, false, particles)
        end
        return particles
    end

    function self.draw(particles)
        if (self.missilePackQuicker == self.MSL_PKG_MUCH_QUICKER) then
            VaisseauPng = love.graphics.newImage("sprites/vaisseau_retro.png")
        elseif (self.missilePackQuicker == self.MSL_PKG_QUICKER) then
            VaisseauPng = love.graphics.newImage("sprites/vaisseau_retro_orange.png")
        else
            VaisseauPng = love.graphics.newImage("sprites/vaisseau_retro_rouge.png")
        end

        -- draw reactor and smoke
        drawPropulsorPositionXY(particles)

        -- circle of protection at start level or with bonus
        if (self.timeShieldStart < self.TIME_SHIELD_START_MAX) then
            printWarningStartLevel()
        end


        local font = love.graphics.newFont("fonts/HeavyData/HeavyDataNerdFont-Regular.ttf", 11)
        love.graphics.setFont(font)
        local offsetPrintV = 0
        local OFF_SET_PRINT_CREDITS_ADDED = 12
        local valueOffset = 100
        love.graphics.setColor(255 / 255, 165 / 255, 0 / 255) -- orange
        love.graphics.print("Protection", (SCREEN_WIDTH / 3), offsetPrintV)
        love.graphics.print(": " .. tostring(string.format("%d", self.protection)), (SCREEN_WIDTH / 3) + valueOffset,
            offsetPrintV)
        love.graphics.setColor(255, 255, 255, 255) -- reset
        offsetPrintV = offsetPrintV + OFF_SET_PRINT_CREDITS_ADDED
        love.graphics.print("Stage", (SCREEN_WIDTH / 3), offsetPrintV)
        love.graphics.print(": " .. tostring(string.format("%d", level.levelNumber)), (SCREEN_WIDTH / 3) + valueOffset,
            offsetPrintV)
        offsetPrintV = offsetPrintV + OFF_SET_PRINT_CREDITS_ADDED
        love.graphics.print("Lateral Weapon", (SCREEN_WIDTH / 3), offsetPrintV)
        love.graphics.print(": " .. tostring(nameMissilePack[self.missilePackLateral]), (SCREEN_WIDTH / 3) + valueOffset,
            offsetPrintV)
        offsetPrintV = offsetPrintV + OFF_SET_PRINT_CREDITS_ADDED
        love.graphics.print("Bigger Weapon", (SCREEN_WIDTH / 3), offsetPrintV)
        love.graphics.print(": " .. tostring(nameMissilePack[self.missilePackBigger]), (SCREEN_WIDTH / 3) + valueOffset,
            offsetPrintV)
        offsetPrintV = offsetPrintV + OFF_SET_PRINT_CREDITS_ADDED
        love.graphics.print("Quick Weapon", (SCREEN_WIDTH / 3), offsetPrintV)
        love.graphics.print(": " .. tostring(nameMissilePack[self.missilePackQuicker]), (SCREEN_WIDTH / 3) + valueOffset,
            offsetPrintV)
        offsetPrintV = offsetPrintV + OFF_SET_PRINT_CREDITS_ADDED
        love.graphics.print("Laser Sight", (SCREEN_WIDTH / 3), offsetPrintV)
        love.graphics.print(": " .. tostring(nameMissilePack[self.missileLaserSight]), (SCREEN_WIDTH / 3) + valueOffset,
            offsetPrintV)
        offsetPrintV = offsetPrintV + OFF_SET_PRINT_CREDITS_ADDED
        love.graphics.print("Shield Protection", (SCREEN_WIDTH / 3), offsetPrintV)
        love.graphics.print(": " .. tostring(nameMissilePack[self.shield]), (SCREEN_WIDTH / 3) + valueOffset,
            offsetPrintV)
        offsetPrintV = offsetPrintV + OFF_SET_PRINT_CREDITS_ADDED
        love.graphics.print("Sinus", (SCREEN_WIDTH / 3), offsetPrintV)
        love.graphics.print(": " .. tostring(nameMissilePack[self.missileSinus]), (SCREEN_WIDTH / 3) + valueOffset,
            offsetPrintV)
        offsetPrintV = offsetPrintV + OFF_SET_PRINT_CREDITS_ADDED

        -- manage laser sight
        if (self.missilePackLateral == self.MSL_PKG_STD or self.missilePackLateral == self.MSL_PKG_MUCH_LATERAL) then
            local X_offsetMissilePositionWithVaisseau = self.GUN_POSITION_X_OFFSET *
            (self.imageRatio / self.imageRatioRef)
            local Y_offsetMissilePositionWithVaisseau = self.GUN_POSITION_Y_OFFSET *
            (self.imageRatio / self.imageRatioRef)
            local X_offsetMissilePositionWithVaisseauAway = SCREEN_WIDTH * (self.imageRatio / self.imageRatioRef)
            local Y_offsetMissilePositionWithVaisseauAway = 0 * (self.imageRatio / self.imageRatioRef)
            if (self.missileLaserSight == self.MSL_LASER_SIGHT) then
                -- draw laser ON
                love.graphics.setColor(255, 0, 0)
                love.graphics.line(
                    self.X_pos + (math.cos(self.angle) * X_offsetMissilePositionWithVaisseau) -
                    (math.sin(self.angle) * Y_offsetMissilePositionWithVaisseau),
                    self.Y_pos + (math.sin(self.angle) * X_offsetMissilePositionWithVaisseau) +
                    (math.cos(self.angle) * Y_offsetMissilePositionWithVaisseau),
                    self.X_pos + (math.cos(self.angle) * X_offsetMissilePositionWithVaisseauAway) -
                    (math.sin(self.angle) * Y_offsetMissilePositionWithVaisseauAway),
                    self.Y_pos + (math.sin(self.angle) * X_offsetMissilePositionWithVaisseauAway) +
                    (math.cos(self.angle) * Y_offsetMissilePositionWithVaisseauAway))
                love.graphics.setColor(255, 255, 255, 255)
            end
        end

        if (self.missilePackLateral == self.MSL_PKG_LATERAL or self.missilePackLateral == self.MSL_PKG_MUCH_LATERAL) then
            local FAR_AWAY = 5000
            local X_offsetMissilePositionWithVaisseauRight = self.SIDE_GUN_POSITION_X_OFFSET *
            (self.imageRatio / self.imageRatioRef)
            local Y_offsetMissilePositionWithVaisseauRight = self.SIDE_GUN_POSITION_Y_OFFSET *
            (self.imageRatio / self.imageRatioRef)
            local X_offsetMissilePositionWithVaisseauRightAway = FAR_AWAY * (self.imageRatio / self.imageRatioRef)
            local Y_offsetMissilePositionWithVaisseauRightAway = 0 * (self.imageRatio / self.imageRatioRef)
            local X_offsetMissilePositionWithVaisseauLeft = self.SIDE_GUN_POSITION_X_OFFSET *
            (self.imageRatio / self.imageRatioRef)
            local Y_offsetMissilePositionWithVaisseauLeft = -self.SIDE_GUN_POSITION_Y_OFFSET *
            (self.imageRatio / self.imageRatioRef)
            local X_offsetMissilePositionWithVaisseauLeftAway = FAR_AWAY * (self.imageRatio / self.imageRatioRef)
            local Y_offsetMissilePositionWithVaisseauLeftAway = 0 * (self.imageRatio / self.imageRatioRef)

            if (self.missileLaserSight == self.MSL_LASER_SIGHT) then
                -- draw laser ON
                love.graphics.setColor(255, 0, 0)

                love.graphics.line(
                    self.X_pos +
                    (math.cos(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauRight) -
                    (math.sin(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauRight),
                    self.Y_pos +
                    (math.sin(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauRight) +
                    (math.cos(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauRight),
                    self.X_pos +
                    (math.cos(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauRightAway) -
                    (math.sin(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauRightAway),
                    self.Y_pos +
                    (math.sin(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauRightAway) +
                    (math.cos(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauRightAway))
                love.graphics.line(
                    self.X_pos +
                    (math.cos(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauLeft) -
                    (math.sin(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauLeft),
                    self.Y_pos +
                    (math.sin(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauLeft) +
                    (math.cos(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauLeft),
                    self.X_pos +
                    (math.cos(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauLeftAway) -
                    (math.sin(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauLeftAway),
                    self.Y_pos +
                    (math.sin(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauLeftAway) +
                    (math.cos(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauLeftAway))
                love.graphics.setColor(255, 255, 255, 255)
            end
        end

        love.graphics.draw(VaisseauPng, self.X_pos, self.Y_pos, self.angle + (0.5 * math.pi), self.imageRatio,
            self.imageRatio, widthImage / 2, heightImage / 2)

        -- vaisseau impact
        if (self.vaisseauImpact == true) then
            love.graphics.draw(VaisseauPngImpact, self.X_pos, self.Y_pos, self.angle + (0.5 * math.pi),
                self.imageRatio, self.imageRatio, widthImage / 2, heightImage / 2)

            vaisseauImpactDuration = vaisseauImpactDuration - 1
            if (vaisseauImpactDuration < 1) then
                vaisseauImpactDuration = IMPACT_DURATION
                self.vaisseauImpact = false
            end
        end
    end

    function self.missileChoice(packOfMissile)
        self.missilePack = packOfMissile
    end

    function self.shoot(typeOfMissile)
        self.toggleShootLeftRight = toggleBool(self.toggleShootLeftRight)
        return Missile.new(self.angle, self.X_pos, self.Y_pos, self.speedX, self.speedY, typeOfMissile,
            self.toggleShootLeftRight)
    end

    function self.activateShield()
        self.shield = self.SHIELD
        self.timeShieldStart = 0
    end

    return self
end

-- ███    ███ ██ ███████ ███████ ██ ██      ███████
-- ████  ████ ██ ██      ██      ██ ██      ██
-- ██ ████ ██ ██ ███████ ███████ ██ ██      █████
-- ██  ██  ██ ██      ██      ██ ██ ██      ██
-- ██      ██ ██ ███████ ███████ ██ ███████ ███████
Missile = {}
Missile.new = function(angle_missile, X_pos_vaisseau, Y_pos_vaisseau, speedX_missile, speedY_missile, type_missile,
                       shootSideToDo)
    local self = GameObject.new()

    self.nameInstance = "MISSILE"

    type_missile = type_missile or self.STD

	-- self.accelerate = 300

    local LATERAL_TAB = 1
    local BIGGER_TAB = 2
    local QUICKER_TAB = 3
    local SINUS = 4

    self.imageRatio = self.imageRatio / 2 -- divided by 2 otherwise missile too big at the start
    self.imageRatioRef = 0.35 / 2         -- divided by 2 otherwise missile too big at the start

    local X_offsetMissilePositionWithVaisseau = 0
    local Y_offsetMissilePositionWithVaisseau = 0
    if (type_missile[BIGGER_TAB] == self.MSL_PKG_BIGGER) then
        self.imageRatio = self.imageRatio * 2
        self.imageRatioRef = self.imageRatioRef * 2
    end

    if (type_missile[BIGGER_TAB] == self.MSL_PKG_MUCH_BIGGER) then
        self.imageRatio = self.imageRatio * 4
        self.imageRatioRef = self.imageRatioRef * 4
    end

    if (type_missile[LATERAL_TAB] == self.MSL_PKG_STD) then
        X_offsetMissilePositionWithVaisseau = self.GUN_POSITION_X_OFFSET * (self.imageRatio / self.imageRatioRef)
        Y_offsetMissilePositionWithVaisseau = self.GUN_POSITION_Y_OFFSET * (self.imageRatio / self.imageRatioRef)
        if (type_missile[QUICKER_TAB] == self.MSL_PKG_QUICKER or type_missile[QUICKER_TAB] == self.MSL_PKG_MUCH_QUICKER) then
            self.angle = angle_missile + randomSign() * (0.2 * love.math.random())
        else
            self.angle = angle_missile                                            
        end
    end

    if (type_missile[LATERAL_TAB] == self.RIGHT) then
        X_offsetMissilePositionWithVaisseau = self.SIDE_GUN_POSITION_X_OFFSET * (self.imageRatio / self.imageRatioRef)
        Y_offsetMissilePositionWithVaisseau = self.SIDE_GUN_POSITION_Y_OFFSET * (self.imageRatio / self.imageRatioRef)
        if (type_missile[QUICKER_TAB] == self.MSL_PKG_QUICKER or type_missile[QUICKER_TAB] == self.MSL_PKG_MUCH_QUICKER) then
            self.angle = angle_missile - self.SIDE_GUN_ANGLE_OFFSET +
            randomSign() * (0.1 * love.math.random())                                                          
        else
            self.angle = angle_missile - self.SIDE_GUN_ANGLE_OFFSET                                            
        end
    end

    if (type_missile[LATERAL_TAB] == self.LEFT) then
        X_offsetMissilePositionWithVaisseau = self.SIDE_GUN_POSITION_X_OFFSET * (self.imageRatio / self.imageRatioRef)
        Y_offsetMissilePositionWithVaisseau = -self.SIDE_GUN_POSITION_Y_OFFSET * (self.imageRatio / self.imageRatioRef)
        if (type_missile[QUICKER_TAB] == self.MSL_PKG_QUICKER or type_missile[QUICKER_TAB] == self.MSL_PKG_MUCH_QUICKER) then
            self.angle = angle_missile + self.SIDE_GUN_ANGLE_OFFSET +
            randomSign() * (0.1 * love.math.random())                                                          
        else
            self.angle = angle_missile + self.SIDE_GUN_ANGLE_OFFSET                                            
        end
    end

    local MissilePng
    if (type_missile[QUICKER_TAB] == self.MSL_PKG_MUCH_QUICKER) then
        MissilePng = love.graphics.newImage("sprites/missile.png")
    elseif (type_missile[QUICKER_TAB] == self.MSL_PKG_QUICKER) then
        MissilePng = love.graphics.newImage("sprites/missile_orange.png")
    else
        MissilePng = love.graphics.newImage("sprites/missile_violet.png")
    end

    self.X_pos = X_pos_vaisseau + (math.cos(self.angle) * X_offsetMissilePositionWithVaisseau) -
    (math.sin(self.angle) * Y_offsetMissilePositionWithVaisseau)
    self.Y_pos = Y_pos_vaisseau + (math.sin(self.angle) * X_offsetMissilePositionWithVaisseau) +
    (math.cos(self.angle) * Y_offsetMissilePositionWithVaisseau)
    self.speedX = speedX_missile
    self.speedY = speedY_missile

    local widthImage = MissilePng:getWidth()
    local heightImage = MissilePng:getHeight()
    self.imageRadius = (widthImage / 2) * self.imageRatio

    function self.draw()
        love.graphics.draw(MissilePng, self.X_pos, self.Y_pos, 0, (self.imageRatio), (self.imageRatio), widthImage / 2,
            heightImage / 2)
    end

    function self.move(dt)
        if (type_missile[SINUS] == self.MSL_SINUS) then
            local beta = self.angle + (math.pi / 2)   -- offset angle by 90 degrees, only run once : doesn't change
            local frequency = 1
            local amplitude = 5
            local phase = math.pi / 2
            if (shootSideToDo == true) then  -- alternate sinus shoot start to left and right
                phase = math.pi / 2
            else
                phase = 3 * (math.pi / 2)
            end
            self.timeInMilliSecond = (love.timer.getTime() * 10 - self.initTimeInMilliSecond)

            current_distance = amplitude * math.sin(self.timeInMilliSecond * frequency + phase);
            self.X_pos = self.X_pos + (math.cos(beta) * current_distance)
            self.Y_pos = self.Y_pos + (math.sin(beta) * current_distance)
            self.X_pos = (self.X_pos + self.speedX*dt)
            self.Y_pos = (self.Y_pos + self.speedY*dt)
        else
            self.X_pos = (self.X_pos + self.speedX*dt)
            self.Y_pos = (self.Y_pos + self.speedY*dt)
        end
    end

    self.initTimeInMilliSecond = love.timer.getTime() * 10

    function self.missile_lost()
        if (self.X_pos > SCREEN_WIDTH or self.X_pos < 0 or self.Y_pos > SCREEN_HIGH or self.Y_pos < 0) then
            return true
        else
            return false
        end
    end

    return self
end

--  █████  ███████ ████████ ███████ ██████   ██████  ██ ██████
-- ██   ██ ██         ██    ██      ██   ██ ██    ██ ██ ██   ██
-- ███████ ███████    ██    █████   ██████  ██    ██ ██ ██   ██
-- ██   ██      ██    ██    ██      ██   ██ ██    ██ ██ ██   ██
-- ██   ██ ███████    ██    ███████ ██   ██  ██████  ██ ██████
Asteroid = {}
Asteroid.new = function()
    local self = GameObject.new()
    self.nameInstance = "ASTEROID"
    local AsteroidPng = love.graphics.newImage("sprites/asteroid_retro.png")
    local AsteroidPngImpact = love.graphics.newImage("sprites/asteroid_retro_impact.png")
    self.asteroidImpact = false
    local IMPACT_DURATION = 10 -- 1/6 second
    local asteroidImpactDuration = IMPACT_DURATION
    self.asteroidDivision = 2
    self.protection = 3

    local widthImage = 0
    local heightImage = 0

    local widthImage = AsteroidPng:getWidth()
    local heightImage = AsteroidPng:getHeight()
    self.imageRadius = (widthImage / 2) * self.imageRatio

    self.imageRatio = 0.55
    self.imageRatioRef = 0.35

    function self.recalculateImageRadius()
        self.imageRadius = (widthImage / 2) * self.imageRatio
    end

    function self.draw()
        if (self.asteroidImpact == false) then
            love.graphics.draw(AsteroidPng, self.X_pos, self.Y_pos, self.angle + (0.5 * math.pi), self.imageRatio,
                self.imageRatio, widthImage / 2, heightImage / 2)
        else
            love.graphics.draw(AsteroidPngImpact, self.X_pos, self.Y_pos, self.angle + (0.5 * math.pi), self.imageRatio,
                self.imageRatio, widthImage / 2, heightImage / 2)
            asteroidImpactDuration = asteroidImpactDuration - 1
            if (asteroidImpactDuration < 1) then
                asteroidImpactDuration = IMPACT_DURATION
                self.asteroidImpact = false
            end
        end
    end

    self.CLOCKWISE = randomBool()
    self.maneuverability = 1 * love.math.random()

    self.X_pos = SCREEN_WIDTH * love.math.random()
    self.Y_pos = SCREEN_HIGH * love.math.random()
    self.angle = 2 * math.pi * love.math.random()
    local MAX_SPEED = 300 * love.math.random()
    self.speedX = MAX_SPEED * randomSign() * love.math.random()
    self.speedY = MAX_SPEED * randomSign() * love.math.random()
    return self
end


-- ██████   ██████  ███    ██ ██    ██ ███████
-- ██   ██ ██    ██ ████   ██ ██    ██ ██
-- ██████  ██    ██ ██ ██  ██ ██    ██ ███████
-- ██   ██ ██    ██ ██  ██ ██ ██    ██      ██
-- ██████   ██████  ██   ████  ██████  ███████

Bonus = {}
Bonus.new = function()
    local self = GameObject.new()
    self.nameInstance = "BONUS"
    local IMPACT_DURATION = 10 -- 1/6 second

    local widthImage = 0
    local heightImage = 0

    local BonusPng
    local MAX_BONUS_NUMBER = (self.MSL_PKG_LAST_END - self.MSL_PKG_LATERAL)

    self.CLOCKWISE = true
    self.maneuverability = 0

    self.imageRatio = 0.55
    self.imageRatioRef = 0.35

    self.X_pos = SCREEN_WIDTH * love.math.random()
    self.Y_pos = SCREEN_HIGH * love.math.random()
    self.angle = 2 * math.pi
    local MAX_SPEED = 3 * love.math.random()
    self.speedX = MAX_SPEED * randomSign() * love.math.random()
    self.speedY = MAX_SPEED * randomSign() * love.math.random()

    local counterIncrease = 1
    local imageRatioChange = nil

    self.bonus = math.floor(2 + love.math.random() * MAX_BONUS_NUMBER)
    if (self.bonus == self.MSL_PKG_LATERAL or self.bonus == self.MSL_PKG_MUCH_LATERAL) then
        BonusPng = love.graphics.newImage("sprites/bonus_triple_shoot.png")
    end
    if (self.bonus == self.MSL_PKG_BIGGER or self.bonus == self.MSL_PKG_MUCH_BIGGER) then
        BonusPng = love.graphics.newImage("sprites/bonus_increase_shoot.png")
    end
    if (self.bonus == self.MSL_PKG_QUICKER or self.bonus == self.MSL_PKG_MUCH_QUICKER) then
        BonusPng = love.graphics.newImage("sprites/bonus_machine_gun_shoot.png")
    end
    if (self.bonus == self.MSL_LASER_SIGHT) then
        BonusPng = love.graphics.newImage("sprites/bonus_vise.png")
    end
    if (self.bonus == self.SHIELD) then
        BonusPng = love.graphics.newImage("sprites/bonus_bouclier.png")
    end
    if (self.bonus == self.MSL_SINUS) then
        BonusPng = love.graphics.newImage("sprites/bonus_sinus_shoot.png")
    end

    local widthImage = BonusPng:getWidth()
    local heightImage = BonusPng:getHeight()
    self.imageRadius = (widthImage / 2) * self.imageRatio

    function self.recalculateImageRadius()
        self.imageRadius = (widthImage / 2) * self.imageRatio
    end

    local startTimeCreation = love.timer.getTime()
    function self.checkLifeTime(maxValue)
        local currentTimeCreation = love.timer.getTime()
        if (currentTimeCreation - startTimeCreation) >= maxValue then
            return true
        else
            return false
        end
    end

    function self.checkLifeTimeFinished()
        return self.checkLifeTime(20)
    end

    function self.checkLifeTimeAlmostFinished()
        return self.checkLifeTime(15)
    end

    function self.draw()
        -- rotation effect with horizontal ratio change of bonus image
        local oneSecond = 60
        local durationSeconds = 2
        counterIncrease = (counterIncrease + 1) % (durationSeconds * oneSecond)
        imageRatioChange = (3 * math.sin((counterIncrease * math.pi) / (durationSeconds * oneSecond))) + 1

        if (self.checkLifeTimeAlmostFinished() == true) then
            if (isEven(math.floor(love.timer.getTime() - startTimeCreation))) then
                love.graphics.draw(BonusPng, self.X_pos, self.Y_pos, self.angle + (2 * math.pi),
                    self.imageRatio / imageRatioChange,
                    self.imageRatio, widthImage / 2, heightImage / 2)
            end
        else
            love.graphics.draw(BonusPng, self.X_pos, self.Y_pos, self.angle + (2 * math.pi),
                self.imageRatio / imageRatioChange,
                self.imageRatio, widthImage / 2, heightImage / 2)
        end
    end

    return self
end
