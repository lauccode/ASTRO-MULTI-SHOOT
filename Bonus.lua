require("utils")
local GameObject = require("GameObject")

local Bonus = {}
Bonus.new = function()
    local self = GameObject.new()
    self.nameInstance = "BONUS"

    local BonusPng
    local MAX_BONUS_NUMBER = (self.MSL_PKG_LAST_END - self.MSL_PKG_LATERAL)

    self.CLOCKWISE = true
    self.maneuverability = 0

    self.imageRatio = 0.55
    self.imageRatioRef = 0.35

    self.position.x = SCREEN_WIDTH * love.math.random()
    self.position.y = SCREEN_HIGH * love.math.random()
    self.angle = 2 * math.pi
    local MAX_SPEED = 3 * love.math.random()
    self.velocity.x = MAX_SPEED * randomSign() * love.math.random()
    self.velocity.y = MAX_SPEED * randomSign() * love.math.random()

    local counterIncrease = 1
    local imageRatioChange = nil

    self.bonus = math.floor(self.MSL_PKG_LATERAL + love.math.random() * MAX_BONUS_NUMBER)

    if (self.bonus == self.MSL_PKG_LATERAL or self.bonus == self.MSL_PKG_MUCH_LATERAL) then
        BonusPng = Assets.images.bonusTripleShoot
    end
    if (self.bonus == self.MSL_PKG_BIGGER or self.bonus == self.MSL_PKG_MUCH_BIGGER) then
        BonusPng = Assets.images.bonusIncreaseShoot
    end
    if (self.bonus == self.MSL_PKG_QUICKER or self.bonus == self.MSL_PKG_MUCH_QUICKER) then
        BonusPng = Assets.images.bonusMachineGunShoot
    end
    if (self.bonus == self.MSL_LASER_SIGHT) then
        BonusPng = Assets.images.bonusVise
    end
    if (self.bonus == self.SHIELD) then
        BonusPng = Assets.images.bonusBouclier
    end
    if (self.bonus == self.MSL_SINUS) then
        BonusPng = Assets.images.bonusSinusShoot
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
        local oneSecond = 60
        local durationSeconds = 2
        counterIncrease = (counterIncrease + 1) % (durationSeconds * oneSecond)
        imageRatioChange = (3 * math.sin((counterIncrease * math.pi) / (durationSeconds * oneSecond))) + 1

        if (self.checkLifeTimeAlmostFinished() == true) then
            if (isEven(math.floor(love.timer.getTime() - startTimeCreation))) then
                love.graphics.draw(BonusPng, self.position.x, self.position.y, self.angle + (2 * math.pi),
                    self.imageRatio / imageRatioChange,
                    self.imageRatio, widthImage / 2, heightImage / 2)
            end
        else
            love.graphics.draw(BonusPng, self.position.x, self.position.y, self.angle + (2 * math.pi),
                self.imageRatio / imageRatioChange,
                self.imageRatio, widthImage / 2, heightImage / 2)
        end
    end

    return self
end

return Bonus
