require("utils")
local GameObject = require("GameObject")
local Missile = require("Missile")
local Vector2 = require("Vector2")

local Vaisseau = {}
Vaisseau.new = function(level)
    local self = GameObject.new()
    self.nameInstance = "VAISSEAU"
    local PropulsorPng = Assets.images.propulsor
    local VaisseauPngImpact1 = Assets.images.vaisseauImpact1
    local VaisseauPngImpact2 = Assets.images.vaisseauImpact2
    local VaisseauPngImpact3 = Assets.images.vaisseauImpact3
    self.vaisseauImpact = false
    local IMPACT_DURATION = 1/6     -- 1/6 second
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

    self.SHOOT_TIMER_LIMIT = 30/60
    self.SHOOT_MACHINE_GUN_TIMER_LIMIT = 20/60
    self.SHOOT_MUCH_MACHINE_GUN_TIMER_LIMIT = 10/60

    local PROPULSOR_LOW_LEFT = 1
    local PROPULSOR_LOW_RIGHT = 2
    local PROPULSOR_HIGHT_LEFT = 3
    local PROPULSOR_HIGHT_RIGHT = 4

    local X_PROPULSOR_LOW_LEFT = -7
    local Y_PROPULSOR_LOW_LEFT = -11
    local X_PROPULSOR_LOW_RIGHT = -7
    local Y_PROPULSOR_LOW_RIGHT = 11

    local X_PROPULSOR_HIGHT_LEFT_3 = 14
    local Y_PROPULSOR_HIGHT_LEFT_3 = -11
    local X_PROPULSOR_HIGHT_RIGHT_3 = 14
    local Y_PROPULSOR_HIGHT_RIGHT_3 = 11

    local X_PROPULSOR_HIGHT_LEFT_2 = 4
    local Y_PROPULSOR_HIGHT_LEFT_2 = -6
    local X_PROPULSOR_HIGHT_RIGHT_2 = 4
    local Y_PROPULSOR_HIGHT_RIGHT_2 = 6

    local X_PROPULSOR_HIGHT_LEFT_1 = 4
    local Y_PROPULSOR_HIGHT_LEFT_1 = -13
    local X_PROPULSOR_HIGHT_RIGHT_1 = 4
    local Y_PROPULSOR_HIGHT_RIGHT_1 = 13

    local propulsorCoordByLateral = {
        [self.MSL_PKG_STD] = {
            left = { x = X_PROPULSOR_HIGHT_LEFT_1, y = Y_PROPULSOR_HIGHT_LEFT_1 },
            right = { x = X_PROPULSOR_HIGHT_RIGHT_1, y = Y_PROPULSOR_HIGHT_RIGHT_1 },
        },
        [self.MSL_PKG_LATERAL] = {
            left = { x = X_PROPULSOR_HIGHT_LEFT_2, y = Y_PROPULSOR_HIGHT_LEFT_2 },
            right = { x = X_PROPULSOR_HIGHT_RIGHT_2, y = Y_PROPULSOR_HIGHT_RIGHT_2 },
        },
        [self.MSL_PKG_MUCH_LATERAL] = {
            left = { x = X_PROPULSOR_HIGHT_LEFT_3, y = Y_PROPULSOR_HIGHT_LEFT_3 },
            right = { x = X_PROPULSOR_HIGHT_RIGHT_3, y = Y_PROPULSOR_HIGHT_RIGHT_3 },
        },
        default = {
            left = { x = X_PROPULSOR_HIGHT_LEFT_1, y = Y_PROPULSOR_HIGHT_LEFT_1 },
            right = { x = X_PROPULSOR_HIGHT_RIGHT_1, y = Y_PROPULSOR_HIGHT_RIGHT_1 },
        }
    }

    local particles = {}
    local smokeImg = Assets.images.smoke
    local particle = {}
    particle.posX = {}
    particle.posY = {}
    local particle_number = 1
    local particleTimer = 0

    local VaisseauPngGreen1 = Assets.images.vaisseauGreen1
    local VaisseauPngGreen2 = Assets.images.vaisseauGreen2
    local VaisseauPngGreen3 = Assets.images.vaisseauGreen3
    local VaisseauPngOrange1 = Assets.images.vaisseauOrange1
    local VaisseauPngOrange2 = Assets.images.vaisseauOrange2
    local VaisseauPngOrange3 = Assets.images.vaisseauOrange3
    local VaisseauPngRed1 = Assets.images.vaisseauRed1
    local VaisseauPngRed2 = Assets.images.vaisseauRed2
    local VaisseauPngRed3 = Assets.images.vaisseauRed3
    -- image lookup tables to avoid nested conditionals and per-frame table rebuild
    local pngByQuicker = {
        [self.MSL_PKG_MUCH_QUICKER] = {
            [self.MSL_PKG_STD] = VaisseauPngGreen1,
            [self.MSL_PKG_LATERAL] = VaisseauPngGreen2,
            [self.MSL_PKG_MUCH_LATERAL] = VaisseauPngGreen3
        },
        [self.MSL_PKG_QUICKER] = {
            [self.MSL_PKG_STD] = VaisseauPngOrange1,
            [self.MSL_PKG_LATERAL] = VaisseauPngOrange2,
            [self.MSL_PKG_MUCH_LATERAL] = VaisseauPngOrange3
        },
        default = {
            [self.MSL_PKG_STD] = VaisseauPngRed1,
            [self.MSL_PKG_LATERAL] = VaisseauPngRed2,
            [self.MSL_PKG_MUCH_LATERAL] = VaisseauPngRed3
        }
    }

    local impactByLateral = {
        [self.MSL_PKG_STD] = VaisseauPngImpact1,
        [self.MSL_PKG_LATERAL] = VaisseauPngImpact2,
        [self.MSL_PKG_MUCH_LATERAL] = VaisseauPngImpact3
    }
    local widthImage = VaisseauPngGreen3:getWidth()
    local heightImage = VaisseauPngGreen3:getHeight()
    local widthImageProp = PropulsorPng:getWidth()
    self.imageRadius = (widthImage / 2) * self.imageRatio

    self.timeShieldStartMax = 5 -- 5 seconds
    self.timeShieldStart = 0
    self.timeShieldInfinite = false

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

    local VaisseauPngMuzzleFlash = Assets.images.muzzleFlash
    local shipAnimationSheet = Assets.images.animation12
    local shipAnimationFrameCount = 7
    local shipAnimationFrameWidth = 100
    local shipAnimationFrameHeight = 107
    local shipAnimationFrameDuration = 0.1 -- 1/10 second
    local shipAnimationQuads = {}
    local shipAnimationActive = false
    local shipAnimationFrame = 1
    local shipAnimationDirection = 1
    local shipAnimationTimer = 0
    local previousMissilePackLateral = self.missilePackLateral

    for frameIndex = 1, shipAnimationFrameCount do
        shipAnimationQuads[frameIndex] = love.graphics.newQuad(
            (frameIndex - 1) * shipAnimationFrameWidth,
            0,
            shipAnimationFrameWidth,
            shipAnimationFrameHeight,
            shipAnimationSheet:getWidth(),
            shipAnimationSheet:getHeight()
        )
    end

    local pngMuzzleFlashWidthImage = VaisseauPngMuzzleFlash:getWidth()
    local pngMuzzleFlashHeightImage = VaisseauPngMuzzleFlash:getHeight()
    
    local timeMuzzleFlashEnable = false
    local timeMuzzleFlash = 0
    local TIME_MUZZLE_FLASH_END = 1/10 -- 1/10 second

    self.selectWeaponBar = 1


    local function shieldCircle(extension)
        for extensionToDo = 1, extension do
            love.graphics.circle("line", self.position.x, self.position.y,
                self.imageRadius * self.MAX_EXTENDED_IMAGE_RADIUS_FACTOR + (extensionToDo - 1))
        end
    end

    function self.updatePrintWarningStartLevel(dt)
        if (self.timeShieldStart < self.timeShieldStartMax and not self.timeShieldInfinite) then
            self.timeShieldStart = self.timeShieldStart + dt
        end
        self.colorValueIncrease = self.colorValueIncrease + (300*dt)
    end

    local function printWarningStartLevel()
        if (self.colorValueIncrease > 255) then self.colorValueIncrease = 0 end
        if not self.timeShieldInfinite then
            love.graphics.setFont(Assets.fonts.nerd18)
            love.graphics.setColor(255, 255, 0)
                love.graphics.print("WARNING - SHIELD OFF IN : " ..
                    tostring(string.format("%d", (self.timeShieldStartMax - self.timeShieldStart))),
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
                local coords = propulsorCoordByLateral[self.missilePackLateral] or propulsorCoordByLateral.default
                return 3, coords.left.x, coords.left.y
            elseif (PropulsorWithV == PROPULSOR_HIGHT_RIGHT) then
                local coords = propulsorCoordByLateral[self.missilePackLateral] or propulsorCoordByLateral.default
                return 4, coords.right.x, coords.right.y
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

    function self.updateShootMuzzleTimerCounter(dt)
        timeMuzzleFlash = timeMuzzleFlash + dt
        if (timeMuzzleFlash > TIME_MUZZLE_FLASH_END) then
            timeMuzzleFlashEnable = false
            timeMuzzleFlash = 0
        end
    end

    local function startShipAnimation(previousPackLateral, nextPackLateral)
        local shouldAnimate = (previousPackLateral == self.MSL_PKG_STD and nextPackLateral ~= self.MSL_PKG_STD)
            or (previousPackLateral ~= self.MSL_PKG_STD and nextPackLateral == self.MSL_PKG_STD)
            or (previousPackLateral == self.MSL_PKG_LATERAL and nextPackLateral == self.MSL_PKG_MUCH_LATERAL)
            or (previousPackLateral == self.MSL_PKG_MUCH_LATERAL and nextPackLateral == self.MSL_PKG_LATERAL)

        if (shouldAnimate == false) then
            return
        end

        shipAnimationActive = true
        shipAnimationTimer = 0
        if (nextPackLateral == self.MSL_PKG_STD) then
            shipAnimationDirection = -1
            shipAnimationFrame = shipAnimationFrameCount
        else
            shipAnimationDirection = 1
            shipAnimationFrame = 1
        end
    end

    function self.updateShipAnimation(dt)
        if (shipAnimationActive == true) then
            shipAnimationTimer = shipAnimationTimer + dt
            if (shipAnimationTimer >= shipAnimationFrameDuration) then
                shipAnimationTimer = shipAnimationTimer - shipAnimationFrameDuration
                shipAnimationFrame = shipAnimationFrame + shipAnimationDirection
                if (shipAnimationFrame < 1 or shipAnimationFrame > shipAnimationFrameCount) then
                    shipAnimationActive = false
                    if (shipAnimationDirection > 0) then
                        shipAnimationFrame = shipAnimationFrameCount
                    else
                        shipAnimationFrame = 1
                    end
                end
            end
        end
    end

    function self.updateImpact(dt)
        if (self.vaisseauImpact == true) then
            vaisseauImpactDuration = vaisseauImpactDuration - dt
            if (vaisseauImpactDuration <= 0) then
                vaisseauImpactDuration = IMPACT_DURATION
                self.vaisseauImpact = false
            end
        end
    end

    -- Precompute weapon/laser/muzzle coordinates in update step
    function self.updateWeaponCoordinates()

        local function calc(offset, angle)
            angle = angle or self.angle
            return Vector2.new(
                self.position.x + (math.cos(angle) * offset.x) - (math.sin(angle) * offset.y),
                self.position.y + (math.sin(angle) * offset.x) + (math.cos(angle) * offset.y)
            )
        end

        -- center weapons
        if (self.missilePackLateral == self.MSL_PKG_STD or self.missilePackLateral == self.MSL_PKG_MUCH_LATERAL) then
            local offsetMissile = Vector2.new(self.GUN_POSITION_X_OFFSET * (self.imageRatio / self.imageRatioRef), self.GUN_POSITION_Y_OFFSET * (self.imageRatio / self.imageRatioRef))
            local offsetMissileAway = Vector2.new(SCREEN_WIDTH * (self.imageRatio / self.imageRatioRef), 0)
            self._missileCenterPos = calc(offsetMissile)
            self._missileCenterAwayPos = calc(offsetMissileAway)

            local offsetFlash = Vector2.new(self.FLASH_POSITION_X_OFFSET * (self.imageRatio / self.imageRatioRef), self.FLASH_POSITION_Y_OFFSET * (self.imageRatio / self.imageRatioRef))
            self._flashCenterPos = calc(offsetFlash)
        else
            self._missileCenterPos = nil
            self._missileCenterAwayPos = nil
            self._flashCenterPos = nil
        end

        -- side weapons
        local function calcSide(sideGunX, sideGunY, sideFlashX, sideFlashY)
            local angleOffset = self.sideGunAngleCoordByLateral[self.missilePackLateral] or self.sideGunAngleCoordByLateral.default
            local FAR_AWAY = 5000

            local offsetRight = Vector2.new(sideGunX * (self.imageRatio / self.imageRatioRef), sideGunY * (self.imageRatio / self.imageRatioRef))
            local offsetLeft = Vector2.new(sideGunX * (self.imageRatio / self.imageRatioRef), -sideGunY * (self.imageRatio / self.imageRatioRef))
            local offsetRightAway = Vector2.new(FAR_AWAY * (self.imageRatio / self.imageRatioRef), 0)
            local offsetLeftAway = Vector2.new(FAR_AWAY * (self.imageRatio / self.imageRatioRef), 0)

            self._missileSideRightPos = calc(offsetRight, self.angle - angleOffset.sideGunAngleOffset)
            self._missileSideLeftPos = calc(offsetLeft, self.angle + angleOffset.sideGunAngleOffset)
            self._missileSideRightAwayPos = calc(offsetRightAway, self.angle - angleOffset.sideGunAngleOffset)
            self._missileSideLeftAwayPos = calc(offsetLeftAway, self.angle + angleOffset.sideGunAngleOffset)

            local offsetFlashR = Vector2.new(sideFlashX * (self.imageRatio / self.imageRatioRef), sideFlashY * (self.imageRatio / self.imageRatioRef))
            local offsetFlashL = Vector2.new(sideFlashX * (self.imageRatio / self.imageRatioRef), -sideFlashY * (self.imageRatio / self.imageRatioRef))
            self._flashSideRightPos = calc(offsetFlashR, self.angle - angleOffset.sideGunAngleOffset)
            self._flashSideLeftPos = calc(offsetFlashL, self.angle + angleOffset.sideGunAngleOffset)
        end

        if (self.missilePackLateral == self.MSL_PKG_LATERAL) then
            calcSide(self.SIDE_GUN_POSITION_X_OFFSET_2, self.SIDE_GUN_POSITION_Y_OFFSET_2, self.SIDE_FLASH_POSITION_X_OFFSET_2, self.SIDE_FLASH_POSITION_Y_OFFSET_2)
        elseif (self.missilePackLateral == self.MSL_PKG_MUCH_LATERAL) then
            calcSide(self.SIDE_GUN_POSITION_X_OFFSET_3, self.SIDE_GUN_POSITION_Y_OFFSET_3, self.SIDE_FLASH_POSITION_X_OFFSET_3, self.SIDE_FLASH_POSITION_Y_OFFSET_3)
        else
            self._missileSideRightPos = nil
            self._missileSideLeftPos = nil
            self._missileSideRightAwayPos = nil
            self._missileSideLeftAwayPos = nil
            self._flashSideRightPos = nil
            self._flashSideLeftPos = nil
        end

    end

    local function drawMuzzleFlash()
        local angleOffset = self.sideGunAngleCoordByLateral[self.missilePackLateral] or self.sideGunAngleCoordByLateral.default

        if timeMuzzleFlashEnable and self._flashCenterPos then
            love.graphics.draw(VaisseauPngMuzzleFlash, self._flashCenterPos.x, self._flashCenterPos.y, self.angle + (0.5 * math.pi), self.imageRatio, self.imageRatio, pngMuzzleFlashWidthImage / 2, pngMuzzleFlashHeightImage / 2)
        end
        if timeMuzzleFlashEnable and self._flashSideRightPos then
            love.graphics.draw(VaisseauPngMuzzleFlash, self._flashSideRightPos.x, self._flashSideRightPos.y, self.angle + (0.5 * math.pi) - angleOffset.sideGunAngleOffset, self.imageRatio, self.imageRatio, pngMuzzleFlashWidthImage / 2, pngMuzzleFlashHeightImage / 2)
        end
        if timeMuzzleFlashEnable and self._flashSideLeftPos then
            love.graphics.draw(VaisseauPngMuzzleFlash, self._flashSideLeftPos.x, self._flashSideLeftPos.y, self.angle + (0.5 * math.pi) + angleOffset.sideGunAngleOffset, self.imageRatio, self.imageRatio, pngMuzzleFlashWidthImage / 2, pngMuzzleFlashHeightImage / 2)
        end
    end

    local function drawLaserSight()
        if (self.missileLaserSight == self.MSL_LASER_SIGHT) then
            love.graphics.setColor(255, 0, 0)
            if self._missileCenterPos and self._missileCenterAwayPos then
                love.graphics.line(self._missileCenterPos.x, self._missileCenterPos.y, self._missileCenterAwayPos.x, self._missileCenterAwayPos.y)
            end
            if self._missileSideRightPos and self._missileSideRightAwayPos then
                love.graphics.line(self._missileSideRightPos.x, self._missileSideRightPos.y, self._missileSideRightAwayPos.x, self._missileSideRightAwayPos.y)
            end
            if self._missileSideLeftPos and self._missileSideLeftAwayPos then
                love.graphics.line(self._missileSideLeftPos.x, self._missileSideLeftPos.y, self._missileSideLeftAwayPos.x, self._missileSideLeftAwayPos.y)
            end
            love.graphics.setColor(255, 255, 255, 255)
        end
    end

    function self.draw()
        -- select main and impact images via table lookups (faster & clearer)
        local row = pngByQuicker[self.missilePackQuicker] or pngByQuicker.default
        VaisseauPng = row[self.missilePackLateral] or row[self.MSL_PKG_STD]
        VaisseauPngImpact = impactByLateral[self.missilePackLateral] or VaisseauPngImpact1

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

        drawMuzzleFlash()
        drawLaserSight()
        drawPropulsorPositionXY()

        if (shipAnimationActive == true and shipAnimationSheet ~= nil) then
            love.graphics.draw(shipAnimationSheet, shipAnimationQuads[shipAnimationFrame], self.position.x, self.position.y,
                self.angle + (0.5 * math.pi), self.imageRatio, self.imageRatio,
                shipAnimationFrameWidth / 2, shipAnimationFrameHeight / 2)
        else
            love.graphics.draw(VaisseauPng, self.position.x, self.position.y, self.angle + (0.5 * math.pi), self.imageRatio,
                self.imageRatio, widthImage / 2, heightImage / 2)
        end
            

        if (self.vaisseauImpact == true) then
            love.graphics.draw(VaisseauPngImpact, self.position.x, self.position.y, self.angle + (0.5 * math.pi),
                self.imageRatio, self.imageRatio, widthImage / 2, heightImage / 2)
        end
    end

    function self.missileChoice(packOfMissile)
        self.missilePack = packOfMissile
    end

    function self.shoot(typeOfMissile)
        timeMuzzleFlashEnable = true
        timeMuzzleFlash = 0
        self.toggleShootLeftRight = toggleBool(self.toggleShootLeftRight)
        return Missile.new(self.angle, self.position.x, self.position.y, self.velocity.x, self.velocity.y, typeOfMissile,
            self.toggleShootLeftRight, self.missilePackLateral)
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

    -- Consolidated per-frame update for the vaisseau
    function self.update(dt)
        if (self.missilePackLateral ~= previousMissilePackLateral) then
            startShipAnimation(previousMissilePackLateral, self.missilePackLateral)
            previousMissilePackLateral = self.missilePackLateral
        end
        self.updateShipAnimation(dt)

        -- update visual/particle systems
        self.updatePropulsor(dt)
        -- update warnings and timers
        self.updatePrintWarningStartLevel(dt)
        -- update smoke particles and movement
        self.smokeParticlesUpdate(dt)
        self.move(dt)
        -- precompute weapon coordinates for draw
        self.updateWeaponCoordinates()
        -- update muzzle flash timer and impact state
        self.updateShootMuzzleTimerCounter(dt)
        self.updateImpact(dt)
    end

    return self
end

return Vaisseau
