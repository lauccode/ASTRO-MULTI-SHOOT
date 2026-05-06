require("utils")
local GameObject = require("GameObject")
local Missile = require("Missile")

local Vaisseau = {}
Vaisseau.new = function(level)
    local self = GameObject.new()
    self.nameInstance = "VAISSEAU"
    local PropulsorPng = Assets.images.propulsor
    local VaisseauPngImpact = Assets.images.vaisseauImpact
    self.vaisseauImpact = false
    local IMPACT_DURATION = 10     -- 1/6 second
    local vaisseauImpactDuration = IMPACT_DURATION
    local PROPULSOR_POWER_MAX = 60 -- 1/6 second
    local propulsorIncreasePowerTab = { 0, 0, 0, 0 }
    local MAX_WEAPON = 3
    local MAX_PROTECTION = 10
    self.protection = MAX_PROTECTION      -- 10

    self.missilePackLateral = self.MSL_PKG_STD
    self.missilePackBigger = self.MSL_PKG_STD
    self.missilePackQuicker = self.MSL_PKG_STD
    self.missileLaserSight = self.MSL_PKG_STD
    self.missileSinus = self.MSL_PKG_STD
    self.shield = self.MSL_PKG_STD

    self.SHOOT_TIMER_LIMIT = 30
    self.SHOOT_MACHINE_GUN_TIMER_LIMIT = 20
    self.SHOOT_MUCH_MACHINE_GUN_TIMER_LIMIT = 10

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

    local particles = {}
    local smokeImg = Assets.images.smoke
    local particle = {}
    particle.posX = {}
    particle.posY = {}
    local particle_number = 1
    local particleTimer = 0

    local VaisseauPng = Assets.images.vaisseauRouge
    local widthImage = VaisseauPng:getWidth()
    local heightImage = VaisseauPng:getHeight()
    local widthImageProp = PropulsorPng:getWidth()
    self.imageRadius = (widthImage / 2) * self.imageRatio

    self.timeShieldStartMax = 60 * 5 -- 5 seconds
    self.timeShieldStart = nil
    self.timeShielInfinite = false

    self.imageRatio = 0.55
    self.imageRatioRef = 0.35

    self.toggleShootLeftRight = false

    self.speed = 180
    self.accelerationMax = 6
    self.missileSpeedMax = 5*60
    self.missileAccelerationMax = 60

    self.colorValueIncrease = 0

    local propulsors = {
        {x = 0, y = 0, power = 0},
        {x = 0, y = 0, power = 0},
        {x = 0, y = 0, power = 0},
        {x = 0, y = 0, power = 0}
    }
    
    local angle_LOW = 0
    local angle_HIGHT = 0

    local fontNerd18 = Assets.fonts.nerd18
    local fontBar = Assets.fonts.bar
    local barGrey = Assets.images.barGrey
    local barRed = Assets.images.barRed
    local barOrange = Assets.images.barOrange
    local barGreen = Assets.images.barGreen
    local VaisseauPngGreen = Assets.images.vaisseauGreen
    local VaisseauPngOrange = Assets.images.vaisseauOrange
    local VaisseauPngRed = Assets.images.vaisseauRouge

    self.selectWeaponBar = 1

    local function shieldCircle(extension)
        for extensionToDo = 1, extension do
            love.graphics.circle("line", self.position.x, self.position.y,
                self.imageRadius * self.MAX_EXTENDED_IMAGE_RADIUS_FACTOR + (extensionToDo - 1))
        end
    end

    function self.updatePrintWarningStartLevel(dt)
        if (self.timeShieldStart < self.timeShieldStartMax and not self.timeShieldInfinite) then
            self.timeShieldStart = self.timeShieldStart + (60*dt)
        end
        self.colorValueIncrease = self.colorValueIncrease + (5*60*dt)
    end

    local function printWarningStartLevel()
        if (self.colorValueIncrease > 255) then self.colorValueIncrease = 0 end
        if not self.timeShieldInfinite then
            love.graphics.setFont(Assets.fonts.nerd18)
            love.graphics.setColor(255, 255, 0)
                love.graphics.print("WARNING - SHIELD OFF IN : " ..
                    tostring(string.format("%d", (self.timeShieldStartMax / 60 - self.timeShieldStart / 60))),
                    self.position.x - widthImage, self.position.y - self.imageRadius * (self.MAX_EXTENDED_IMAGE_RADIUS_FACTOR + 1))
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setColor(love.math.colorFromBytes(self.colorValueIncrease, 0, 0))
        shieldCircle(3)
        love.graphics.setColor(255, 255, 255, 255)
    end

    function self.activateShield(infinite)
        infinite = infinite or false
        self.timeShieldInfinite = infinite
        self.timeShieldStart = 0
        if (infinite) then
            self.shield = self.SHIELD
        else
            self.shield = self.MSL_PKG_STD
        end
    end

    local function propulsorIncreasePow(PropulsorWithV, active)
        if (active) then
            if (propulsorIncreasePowerTab[PropulsorWithV] < PROPULSOR_POWER_MAX) then
                propulsorIncreasePowerTab[PropulsorWithV] = propulsorIncreasePowerTab[PropulsorWithV] + 1
            end
        else
            propulsorIncreasePowerTab[PropulsorWithV] = 0
        end
        return propulsorIncreasePowerTab[PropulsorWithV]
    end

    local function updateParticles(dt, active, propulsorX, propulsorY, propulsorIncreasePower)
        if (active == true) then
            particle.posX[particle_number] = propulsorX
            particle.posY[particle_number] = propulsorY
            particles[particle_number] = love.graphics.newParticleSystem(smokeImg, propulsorIncreasePower)
            particles[particle_number]:start()
            particles[particle_number]:setEmissionRate(2 * propulsorIncreasePower)
            particles[particle_number]:setSpeed(10, 50)
            particles[particle_number]:setDirection(1 / 2 * (math.pi))
            particles[particle_number]:setParticleLifetime(1, 2)
            particles[particle_number]:setSizeVariation(1)
            particles[particle_number]:setLinearAcceleration(-30, -30, 30, 30)
            particles[particle_number]:setColors(1, 1, 1, 1, 1, 1, 1, 0)
        else
            particle.posX[particle_number] = propulsorX
            particle.posY[particle_number] = propulsorY
            particles[particle_number] = love.graphics.newParticleSystem(smokeImg, 1)
            particles[particle_number]:stop()
        end

        for particles_it = 1, #particles do
            local powerParticle = particles[particles_it]:getEmissionRate()
            particles[particles_it]:setEmissionRate(powerParticle / 1.05)
        end

        if (particleTimer > 8) then
            particle_number = 1
            particleTimer = 0
        else
            particleTimer = particleTimer + dt
            particle_number = particle_number + 1
        end
        return particles
    end

    function self.smokeParticlesUpdate(dt)
        for particles_it = 1, #particles do
            particles[particles_it]:update(dt)
        end
    end

    local function updatePropulsorParticles(dt, PropulsorWithV, active)
        local function getPropulsorParams(PropulsorWithV)
            if (PropulsorWithV == PROPULSOR_LOW_LEFT) then
                return 1, X_PROPULSOR_LOW_LEFT, Y_PROPULSOR_LOW_LEFT
            elseif (PropulsorWithV == PROPULSOR_LOW_RIGHT) then
                return 2, X_PROPULSOR_LOW_RIGHT, Y_PROPULSOR_LOW_RIGHT
            elseif (PropulsorWithV == PROPULSOR_HIGHT_LEFT) then
                return 3, X_PROPULSOR_HIGHT_LEFT, Y_PROPULSOR_HIGHT_LEFT
            elseif (PropulsorWithV == PROPULSOR_HIGHT_RIGHT) then
                return 4, X_PROPULSOR_HIGHT_RIGHT, Y_PROPULSOR_HIGHT_RIGHT
            end
        end
        
        local idx, x_prop, y_prop = getPropulsorParams(PropulsorWithV)
        
        if idx then
            local x_offset = x_prop * (self.imageRatio / self.imageRatioRef)
            local y_offset = y_prop * (self.imageRatio / self.imageRatioRef)
            propulsors[idx].x = self.position.x + (math.cos(self.angle) * x_offset) - (math.sin(self.angle) * y_offset)
            propulsors[idx].y = self.position.y + (math.sin(self.angle) * x_offset) + (math.cos(self.angle) * y_offset)
            propulsors[idx].power = propulsorIncreasePow(PropulsorWithV, active)
            updateParticles(dt, active, propulsors[idx].x, propulsors[idx].y, propulsors[idx].power)
        end
    end

    local function updatePropulsorDrawPositionXY(dt, PropulsorWithV, active)
        active = active or false
        angle_LOW =  self.angle + (0.5 * math.pi)
        angle_HIGHT =  self.angle + (3 / 2 * math.pi)
        updatePropulsorParticles(dt, PropulsorWithV, active)
    end

    function self.updatePropulsor(dt)
        if (self.accelerateFWorWW == "forward") then
            updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_LEFT, true)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_RIGHT, true)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_LEFT, false)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_RIGHT, false)
        elseif (self.accelerateFWorWW == "backward") then
            updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_LEFT, true)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_RIGHT, true)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_LEFT, false)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_RIGHT, false)
        elseif (self.accelerateFWorWW == "neutral" and self.rotateRightorLeft == "neutral") then
            updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_LEFT, false)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_RIGHT, false)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_LEFT, false)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_RIGHT, false)
        end

        if (self.rotateRightorLeft == "left") then
            updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_RIGHT, true)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_LEFT, true)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_LEFT, false)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_RIGHT, false)
        elseif (self.rotateRightorLeft == "right") then
            updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_LEFT, true)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_RIGHT, true)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_LOW_RIGHT, false)
            updatePropulsorDrawPositionXY(dt, PROPULSOR_HIGHT_LEFT, false)
        end
    end

    local function drawPropulsorPositionXY()
        for particles_it = 1, #particles do
            local powerParticle = particles[particles_it]:getEmissionRate()
            particles[particles_it]:setEmissionRate(powerParticle / 1.05)
            love.graphics.draw(particles[particles_it], particle.posX[particles_it], particle.posY[particles_it])
        end

        local angles = {angle_LOW, angle_LOW, angle_HIGHT, angle_HIGHT}
        for i = 1, 4 do
            love.graphics.draw(
                PropulsorPng,
                propulsors[i].x,
                propulsors[i].y,
                angles[i],
                self.imageRatio * ((love.math.random() * 5 + 5) / 10),
                (self.imageRatio * 2) * (propulsors[i].power / PROPULSOR_POWER_MAX),
                widthImageProp / 2,
                0
            )
        end
    end

    local function drawBar(barLevel, posH, posV, MAX)
        local horizOffset = 21 * self.imageRatio
        for protectionLoop = 1, barLevel do
            local lowLimit = (MAX<3) and MAX/2 or MAX/3
            if (barLevel <= lowLimit ) then
                love.graphics.draw(barRed, posH, posV, 0, self.imageRatio, self.imageRatio, 1, 1)
            elseif (barLevel > MAX/3 and barLevel <= (MAX/3)*2 ) then
                love.graphics.draw(barOrange, posH, posV, 0, self.imageRatio, self.imageRatio, 1, 1)
            elseif (barLevel > (MAX/3)*2 ) then
                love.graphics.draw(barGreen, posH, posV, 0, self.imageRatio, self.imageRatio, 1, 1)
            end
            posH = posH + horizOffset
        end
        for protectionLoop = barLevel, (MAX-1) do
            love.graphics.draw(barGrey, posH, posV, 0, self.imageRatio, self.imageRatio, 1, 1)
            posH = posH + horizOffset
        end
    end

    local function selectBar(OFF_SET_PRINT_CREDITS_ADDED, valueOffset)
        local width = 10
        local high = SCREEN_HIGH - 20

        if (self.selectWeaponBar == 1) then
            love.graphics.print("Lateral Weapon", width, high)
            drawBar(self.lookupWeaponsLevel[self.missilePackLateral], width + valueOffset, high,
                MAX_WEAPON);
        elseif (self.selectWeaponBar == 2) then
            love.graphics.print("Bigger Weapon", width, high)
            drawBar(self.lookupWeaponsLevel[self.missilePackBigger], width + valueOffset, high, MAX_WEAPON);
        elseif (self.selectWeaponBar == 3) then
            love.graphics.print("Quick Weapon", width, high)
            drawBar(self.lookupWeaponsLevel[self.missilePackQuicker], width + valueOffset, high,
                MAX_WEAPON);
        elseif (self.selectWeaponBar == 4) then
            love.graphics.print("Laser Sight", width, high)
            drawBar(self.lookupWeaponsLevel[self.missileLaserSight], width + valueOffset, high,
                MAX_WEAPON - 1);
        elseif (self.selectWeaponBar == 5) then
            love.graphics.print("Sinus", width, high)
            drawBar(self.lookupWeaponsLevel[self.missileSinus], width + valueOffset, high, MAX_WEAPON - 1);
        elseif (self.selectWeaponBar == 6) then
            love.graphics.print("Shield Protection", width, high)
            drawBar(self.lookupWeaponsLevel[self.shield], width + valueOffset, high, MAX_WEAPON - 1);
        end
    end

    function self.draw()
        if (self.missilePackQuicker == self.MSL_PKG_MUCH_QUICKER) then
            VaisseauPng = VaisseauPngGreen
        elseif (self.missilePackQuicker == self.MSL_PKG_QUICKER) then
            VaisseauPng = VaisseauPngOrange
        else
            VaisseauPng = VaisseauPngRed
        end

        drawPropulsorPositionXY()

        if (self.timeShieldStart < self.timeShieldStartMax) then
            printWarningStartLevel()
        end

        love.graphics.setFont(Assets.fonts.bar)
        local offsetPrintV = 0
        local OFF_SET_PRINT_CREDITS_ADDED = 12
        local valueOffset = 100

        love.graphics.setColor(255 / 255, 165 / 255, 0 / 255)
        love.graphics.print("Protection", (SCREEN_WIDTH / 4), offsetPrintV)
        love.graphics.setColor(255, 255, 255, 255)
        drawBar(self.protection, (SCREEN_WIDTH / 5) + valueOffset, offsetPrintV, MAX_PROTECTION);

        selectBar(OFF_SET_PRINT_CREDITS_ADDED, valueOffset)

        offsetPrintV = offsetPrintV + OFF_SET_PRINT_CREDITS_ADDED
        love.graphics.print("Stage", (SCREEN_WIDTH - 60), SCREEN_HIGH - 20)
        love.graphics.print(": " .. tostring(string.format("%d", level.levelNumber)), (SCREEN_WIDTH - (60 - 30)),
            SCREEN_HIGH - 20)
        offsetPrintV = offsetPrintV + OFF_SET_PRINT_CREDITS_ADDED

        if (self.missilePackLateral == self.MSL_PKG_STD or self.missilePackLateral == self.MSL_PKG_MUCH_LATERAL) then
            local X_offsetMissilePositionWithVaisseau = self.GUN_POSITION_X_OFFSET *
            (self.imageRatio / self.imageRatioRef)
            local Y_offsetMissilePositionWithVaisseau = self.GUN_POSITION_Y_OFFSET *
            (self.imageRatio / self.imageRatioRef)
            local X_offsetMissilePositionWithVaisseauAway = SCREEN_WIDTH * (self.imageRatio / self.imageRatioRef)
            local Y_offsetMissilePositionWithVaisseauAway = 0 * (self.imageRatio / self.imageRatioRef)
            if (self.missileLaserSight == self.MSL_LASER_SIGHT) then
                love.graphics.setColor(255, 0, 0)
                love.graphics.line(
                    self.position.x + (math.cos(self.angle) * X_offsetMissilePositionWithVaisseau) -
                    (math.sin(self.angle) * Y_offsetMissilePositionWithVaisseau),
                    self.position.y + (math.sin(self.angle) * X_offsetMissilePositionWithVaisseau) +
                    (math.cos(self.angle) * Y_offsetMissilePositionWithVaisseau),
                    self.position.x + (math.cos(self.angle) * X_offsetMissilePositionWithVaisseauAway) -
                    (math.sin(self.angle) * Y_offsetMissilePositionWithVaisseauAway),
                    self.position.y + (math.sin(self.angle) * X_offsetMissilePositionWithVaisseauAway) +
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
                love.graphics.setColor(255, 0, 0)

                love.graphics.line(
                    self.position.x +
                    (math.cos(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauRight) -
                    (math.sin(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauRight),
                    self.position.y +
                    (math.sin(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauRight) +
                    (math.cos(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauRight),
                    self.position.x +
                    (math.cos(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauRightAway) -
                    (math.sin(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauRightAway),
                    self.position.y +
                    (math.sin(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauRightAway) +
                    (math.cos(self.angle - self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauRightAway))
                love.graphics.line(
                    self.position.x +
                    (math.cos(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauLeft) -
                    (math.sin(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauLeft),
                    self.position.y +
                    (math.sin(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauLeft) +
                    (math.cos(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauLeft),
                    self.position.x +
                    (math.cos(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauLeftAway) -
                    (math.sin(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauLeftAway),
                    self.position.y +
                    (math.sin(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * X_offsetMissilePositionWithVaisseauLeftAway) +
                    (math.cos(self.angle + self.SIDE_GUN_ANGLE_OFFSET) * Y_offsetMissilePositionWithVaisseauLeftAway))
                love.graphics.setColor(255, 255, 255, 255)
            end
        end

        love.graphics.draw(VaisseauPng, self.position.x, self.position.y, self.angle + (0.5 * math.pi), self.imageRatio,
            self.imageRatio, widthImage / 2, heightImage / 2)

        if (self.vaisseauImpact == true) then
            love.graphics.draw(VaisseauPngImpact, self.position.x, self.position.y, self.angle + (0.5 * math.pi),
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
        return Missile.new(self.angle, self.position.x, self.position.y, self.velocity.x, self.velocity.y, typeOfMissile,
            self.toggleShootLeftRight)
    end

    function self.isAllWeaponFulllyUpgraded()
        if (self.missilePackLateral == self.MSL_PKG_MUCH_LATERAL) and
            (self.missilePackBigger == self.MSL_PKG_MUCH_BIGGER) and
            (self.missilePackQuicker == self.MSL_PKG_MUCH_QUICKER) and
            (self.missileLaserSight == self.MSL_LASER_SIGHT) and
            (self.missileSinus == self.MSL_SINUS) and
            (self.shield == self.SHIELD) then
            return true
        else
            return false
        end
    end

    return self
end

return Vaisseau
