require("utils")
local GameObject = require("GameObject")

local Asteroid = {}
Asteroid.new = function()
    local self = GameObject.new()
    self.nameInstance = "ASTEROID"
    local AsteroidPng = Assets.images.asteroid
    local AsteroidPngImpact = Assets.images.asteroidImpact
    self.asteroidImpact = false
    local IMPACT_DURATION = 10
    local asteroidImpactDuration = IMPACT_DURATION
    self.asteroidDivision = 2
    self.protection = 3

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
            love.graphics.draw(AsteroidPng, self.position.x, self.position.y, self.angle + (0.5 * math.pi), self.imageRatio,
                self.imageRatio, widthImage / 2, heightImage / 2)
        else
            love.graphics.draw(AsteroidPngImpact, self.position.x, self.position.y, self.angle + (0.5 * math.pi), self.imageRatio,
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

    self.position.x = SCREEN_WIDTH * love.math.random()
    self.position.y = SCREEN_HIGH * love.math.random()
    self.angle = 2 * math.pi * love.math.random()
    local MAX_SPEED = 300 * love.math.random()
    self.velocity.x = MAX_SPEED * randomSign() * love.math.random()
    self.velocity.y = MAX_SPEED * randomSign() * love.math.random()
    return self
end

return Asteroid
