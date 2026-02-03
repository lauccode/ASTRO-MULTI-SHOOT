require("utils")
local GameObject = require("GameObject")

local Missile = {}
Missile.new = function(angle_missile, X_pos_vaisseau, Y_pos_vaisseau, speedX_missile, speedY_missile, type_missile, shootSideToDo)
    local self = GameObject.new()
    self.nameInstance = "MISSILE"

    type_missile = type_missile or self.STD

    local LATERAL_TAB = 1
    local BIGGER_TAB = 2
    local QUICKER_TAB = 3
    local SINUS = 4

    local MissilePngGreen = Assets.images.missileGreen
    local MissilePngOrange = Assets.images.missileOrange
    local MissilePngRed = Assets.images.missileRed

    self.imageRatio = self.imageRatio / 2
    self.imageRatioRef = 0.35 / 2

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
            self.angle = angle_missile - self.SIDE_GUN_ANGLE_OFFSET + randomSign() * (0.1 * love.math.random())
        else
            self.angle = angle_missile - self.SIDE_GUN_ANGLE_OFFSET
        end
    end

    if (type_missile[LATERAL_TAB] == self.LEFT) then
        X_offsetMissilePositionWithVaisseau = self.SIDE_GUN_POSITION_X_OFFSET * (self.imageRatio / self.imageRatioRef)
        Y_offsetMissilePositionWithVaisseau = -self.SIDE_GUN_POSITION_Y_OFFSET * (self.imageRatio / self.imageRatioRef)
        if (type_missile[QUICKER_TAB] == self.MSL_PKG_QUICKER or type_missile[QUICKER_TAB] == self.MSL_PKG_MUCH_QUICKER) then
            self.angle = angle_missile + self.SIDE_GUN_ANGLE_OFFSET + randomSign() * (0.1 * love.math.random())
        else
            self.angle = angle_missile + self.SIDE_GUN_ANGLE_OFFSET
        end
    end

    local MissilePng
    if (type_missile[QUICKER_TAB] == self.MSL_PKG_MUCH_QUICKER) then
        MissilePng = MissilePngGreen
    elseif (type_missile[QUICKER_TAB] == self.MSL_PKG_QUICKER) then
        MissilePng = MissilePngOrange
    else
        MissilePng = MissilePngRed
    end

    self.position.x = X_pos_vaisseau + (math.cos(self.angle) * X_offsetMissilePositionWithVaisseau) -
    (math.sin(self.angle) * Y_offsetMissilePositionWithVaisseau)
    self.position.y = Y_pos_vaisseau + (math.sin(self.angle) * X_offsetMissilePositionWithVaisseau) +
    (math.cos(self.angle) * Y_offsetMissilePositionWithVaisseau)
    self.velocity.x = speedX_missile
    self.velocity.y = speedY_missile

    local widthImage = MissilePng:getWidth()
    local heightImage = MissilePng:getHeight()
    self.imageRadius = (widthImage / 2) * self.imageRatio

    function self.draw()
        love.graphics.draw(MissilePng, self.position.x, self.position.y, 0, (self.imageRatio), (self.imageRatio), widthImage / 2,
            heightImage / 2)
    end

    function self.move(dt)
        if (type_missile[SINUS] == self.MSL_SINUS) then
            local beta = self.angle + (math.pi / 2)
            local frequency = 1
            local amplitude = 5
            local phase = math.pi / 2
            if (shootSideToDo == true) then
                phase = math.pi / 2
            else
                phase = 3 * (math.pi / 2)
            end
            self.timeInMilliSecond = (love.timer.getTime() * 10 - self.initTimeInMilliSecond)
            current_distance = amplitude * math.sin(self.timeInMilliSecond * frequency + phase);
            self.position.x = self.position.x + (math.cos(beta) * current_distance)
            self.position.y = self.position.y + (math.sin(beta) * current_distance)
            self.position.x = (self.position.x + self.velocity.x * dt)
            self.position.y = (self.position.y + self.velocity.y * dt)
        else
            self.position.x = (self.position.x + self.velocity.x * dt)
            self.position.y = (self.position.y + self.velocity.y * dt)
        end
    end

    self.initTimeInMilliSecond = love.timer.getTime() * 10

    function self.missile_lost()
        if (self.position.x > SCREEN_WIDTH or self.position.x < 0 or self.position.y > SCREEN_HIGH or self.position.y < 0) then
            return true
        else
            return false
        end
    end

    return self
end

return Missile
